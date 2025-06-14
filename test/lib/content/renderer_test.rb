# frozen_string_literal: true

require_relative '../../test_helper'

class ContentRendererTest < ActiveSupport::TestCase
  class TestTag < ComfortableMediaSurfer::Content::Tag
    def content
      'test tag content'
    end
  end

  class TestNestedTag < ComfortableMediaSurfer::Content::Tag
    def content
      'test {{cms:test}} content'
    end
  end

  class TestBlockTag < ComfortableMediaSurfer::Content::Block
    # ...
  end

  DEFAULT_REGISTERED_TAGS = {
    'wysiwyg' => ComfortableMediaSurfer::Content::Tags::Wysiwyg,
    'text' => ComfortableMediaSurfer::Content::Tags::Text,
    'textarea' => ComfortableMediaSurfer::Content::Tags::Textarea,
    'markdown' => ComfortableMediaSurfer::Content::Tags::Markdown,
    'datetime' => ComfortableMediaSurfer::Content::Tags::Datetime,
    'date' => ComfortableMediaSurfer::Content::Tags::Date,
    'number' => ComfortableMediaSurfer::Content::Tags::Number,
    'checkbox' => ComfortableMediaSurfer::Content::Tags::Checkbox,
    'file' => ComfortableMediaSurfer::Content::Tags::File,
    'files' => ComfortableMediaSurfer::Content::Tags::Files,
    'snippet' => ComfortableMediaSurfer::Content::Tags::Snippet,
    'asset' => ComfortableMediaSurfer::Content::Tags::Asset,
    'file_link' => ComfortableMediaSurfer::Content::Tags::FileLink,
    'image' => ComfortableMediaSurfer::Content::Tags::Image,
    'page_file_link' => ComfortableMediaSurfer::Content::Tags::PageFileLink,
    'helper' => ComfortableMediaSurfer::Content::Tags::Helper,
    'partial' => ComfortableMediaSurfer::Content::Tags::Partial,
    'template' => ComfortableMediaSurfer::Content::Tags::Template,
    'audio' => ComfortableMediaSurfer::Content::Tags::Audio,
    'breadcrumbs' => ComfortableMediaSurfer::Content::Tags::Breadcrumbs,
    'children' => ComfortableMediaSurfer::Content::Tags::Children,
    'siblings' => ComfortableMediaSurfer::Content::Tags::Siblings
  }.freeze

  setup do
    @page     = comfy_cms_pages(:default)
    @template = ComfortableMediaSurfer::Content::Renderer.new(@page)

    ComfortableMediaSurfer::Content::Renderer.register_tag(:test, TestTag)
    ComfortableMediaSurfer::Content::Renderer.register_tag(:test_nested, TestNestedTag)
    ComfortableMediaSurfer::Content::Renderer.register_tag(:test_block, TestBlockTag)
  end

  teardown do
    ComfortableMediaSurfer::Content::Renderer.tags.delete('test')
    ComfortableMediaSurfer::Content::Renderer.tags.delete('test_nested')
    ComfortableMediaSurfer::Content::Renderer.tags.delete('test_block')
  end

  # Test helper so we don't have to do this each time
  def render_string(string, template = @template)
    tokens = template.tokenize(string)
    nodes  = template.nodes(tokens)
    template.render(nodes)
  end

  # -- Tests -------------------------------------------------------------------

  def test_tags
    assert_equal DEFAULT_REGISTERED_TAGS.merge(
      'test' => ContentRendererTest::TestTag,
      'test_nested' => ContentRendererTest::TestNestedTag,
      'test_block' => ContentRendererTest::TestBlockTag
    ), ComfortableMediaSurfer::Content::Renderer.tags
  end

  def test_register_tags
    ComfortableMediaSurfer::Content::Renderer.register_tag(:other, TestTag)
    assert_equal DEFAULT_REGISTERED_TAGS.merge(
      'test' => ContentRendererTest::TestTag,
      'test_nested' => ContentRendererTest::TestNestedTag,
      'test_block' => ContentRendererTest::TestBlockTag,
      'other' => ContentRendererTest::TestTag
    ), ComfortableMediaSurfer::Content::Renderer.tags
  ensure
    ComfortableMediaSurfer::Content::Renderer.tags.delete('other')
  end

  def test_tokenize
    assert_equal ['test text'], @template.tokenize('test text')
  end

  def test_tokenize_with_tag
    assert_equal ['test ', { tag_class: 'tag', tag_params: '', source: '{{cms:tag}}' }, ' text'],
                 @template.tokenize('test {{cms:tag}} text')
  end

  def test_tokenize_with_tag_and_params
    expected = [
      'test ',
      { tag_class: 'tag', tag_params: 'name, key:val', source: '{{cms:tag name, key:val}}' },
      ' text'
    ]
    assert_equal expected, @template.tokenize('test {{cms:tag name, key:val}} text')
  end

  def test_tokenize_with_invalid_tag
    assert_equal ['test {{abc:tag}} text'],
                 @template.tokenize('test {{abc:tag}} text')
  end

  def test_tokenize_with_newlines
    expected = [
      { tag_class: 'test', tag_params: '', source: '{{cms:test}}' },
      "\n",
      { tag_class: 'test', tag_params: '', source: '{{cms:test}}' }
    ]
    assert_equal expected, @template.tokenize("{{cms:test}}\n{{cms:test}}")
  end

  def test_nodes
    tokens = @template.tokenize('test')
    nodes = @template.nodes(tokens)
    assert_equal ['test'], nodes
  end

  def test_nodes_with_tags
    tokens = @template.tokenize('test {{cms:test}} content {{cms:test}}')
    nodes = @template.nodes(tokens)
    assert_equal 4, nodes.count
    assert_equal 'test ', nodes[0]
    assert nodes[1].is_a?(ContentRendererTest::TestTag)
    assert_equal ' content ', nodes[2]
    assert nodes[3].is_a?(ContentRendererTest::TestTag)
  end

  def test_nodes_with_tag_with_params
    tokens = @template.tokenize('{{cms:test param, key: value}}')
    nodes = @template.nodes(tokens)
    assert_equal 1, nodes.count
    assert nodes[0].is_a?(ContentRendererTest::TestTag)
    tag = nodes[0]
    assert_equal @page, tag.context
    assert_equal ['param', { 'key' => 'value' }], tag.params
    assert_equal '{{cms:test param, key: value}}', tag.source
  end

  def test_nodes_with_block_tag
    string = 'a {{cms:test_block}} b {{cms:end}} c'
    tokens = @template.tokenize(string)
    nodes = @template.nodes(tokens)
    assert_equal 3, nodes.count

    assert_equal 'a ', nodes[0]
    assert_equal ' c', nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentRendererTest::TestBlockTag)
    assert_equal [' b '], block.nodes
  end

  def test_nodes_with_block_tag_and_tag
    string = 'a {{cms:test_block}} b {{cms:test}} c {{cms:end}} d'
    tokens = @template.tokenize(string)
    nodes = @template.nodes(tokens)
    assert_equal 3, nodes.count
    assert_equal 'a ', nodes[0]
    assert_equal ' d', nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentRendererTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal ' b ', block.nodes[0]
    assert_equal ' c ', block.nodes[2]

    tag = block.nodes[1]
    assert tag.is_a?(ContentRendererTest::TestTag)
    assert_equal ['test tag content'], tag.nodes
  end

  def test_nodes_with_nested_block_tag
    string = 'a {{cms:test_block}} b {{cms:test_block}} c {{cms:end}} d {{cms:end}} e'
    tokens = @template.tokenize(string)
    nodes = @template.nodes(tokens)
    assert_equal 3, nodes.count
    assert_equal 'a ', nodes[0]
    assert_equal ' e', nodes[2]

    block = nodes[1]
    assert block.is_a?(ContentRendererTest::TestBlockTag)
    assert_equal 3, block.nodes.count
    assert_equal ' b ', block.nodes[0]
    assert_equal ' d ', block.nodes[2]

    block = block.nodes[1]
    assert_equal [' c '], block.nodes
  end

  def test_nodes_with_unclosed_block_tag
    string = 'a {{cms:test_block}} b'
    tokens = @template.tokenize(string)
    message = 'unclosed block detected'
    assert_raises ComfortableMediaSurfer::Content::Renderer::SyntaxError, message do
      @template.nodes(tokens)
    end
  end

  def test_nodes_with_closed_tag
    string = 'a {{cms:end}} b'
    tokens = @template.tokenize(string)
    message = 'closing unopened block'
    assert_raises ComfortableMediaSurfer::Content::Renderer::SyntaxError, message do
      @template.nodes(tokens)
    end
  end

  def test_nodes_with_invalid_tag
    string = 'a {{cms:invalid}} b'
    tokens = @template.tokenize(string)
    message = 'Unrecognized tag: {{cms:invalid}}'
    assert_raises ComfortableMediaSurfer::Content::Renderer::SyntaxError, message do
      @template.nodes(tokens)
    end
  end

  def test_sanitize_erb
    out = @template.sanitize_erb('<% test %>', false)
    assert_equal '&lt;% test %&gt;', out

    out = @template.sanitize_erb('<% test %>', true)
    assert_equal '<% test %>', out
  end

  def test_render
    out = render_string('test')
    assert_equal 'test', out
  end

  def test_render_with_tag
    out = render_string('a {{cms:text content}} z')
    assert_equal 'a content z', out
  end

  def test_render_with_erb
    out = render_string('<%= 1 + 1 %>')
    assert_equal '&lt;%= 1 + 1 %&gt;', out
  end

  def test_render_with_erb_allowed
    ComfortableMediaSurfer.config.allow_erb = true
    out = render_string('<%= 1 + 1 %>')
    assert_equal '<%= 1 + 1 %>', out
  end

  def test_render_with_erb_allowed_via_tag
    out = render_string('{{cms:partial path}}')
    assert_equal '<%= render partial: "path", locals: {} %>', out
  end

  def test_render_with_nested_tag
    string = 'a {{cms:text content}} b'
    comfy_cms_fragments(:default).update_column(:content, 'c {{cms:snippet default}} d')
    comfy_cms_snippets(:default).update_column(:content, 'e {{cms:helper test}} f')
    out = render_string(string)
    assert_equal 'a c e <%= test() %> f d b', out
  end

  def test_render_stack_overflow
    # making self-referencing content loop here
    comfy_cms_snippets(:default).update_column(:content, 'a {{cms:snippet default}} b')
    message = 'Deep tag nesting or recursive nesting detected'
    assert_raises ComfortableMediaSurfer::Content::Renderer::Error, message do
      render_string('{{cms:snippet default}}')
    end
  end

  def test_render_with_more_than_max_depth_tags_but_without_stack_overflow
    test_string =
      Array.new(ComfortableMediaSurfer::Content::Renderer::MAX_DEPTH * 2) { '{{cms:text content}}' }.join(' ')
    out = render_string(test_string)
    expected =
      Array.new(ComfortableMediaSurfer::Content::Renderer::MAX_DEPTH * 2) { 'content' }.join(' ')
    assert_equal expected, out
  end
end
