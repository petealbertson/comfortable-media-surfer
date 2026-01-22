# GlitchTip JavaScript Error Reporting Setup

## Overview

GlitchTip JavaScript SDK has been integrated to capture client-side errors, particularly for file upload operations.

## Configuration

### Environment Variables

Set the following environment variable to enable error reporting:

```bash
GLITCHTIP_DSN=https://[key]@glitchtip.example.com/[project-id]
```

**Optional:** Enable error reporting in development mode:
```bash
GLITCHTIP_SEND_IN_DEV=true
```

### Getting Your DSN

1. Log into your GlitchTip instance
2. Navigate to your project settings
3. Find the "Client Keys (DSN)" section
4. Copy the DSN URL

### Example Configuration

**For production (Heroku, etc.):**
```bash
heroku config:set GLITCHTIP_DSN=https://abc123@glitchtip.yourcompany.com/1
```

**For local development (.env file):**
```
GLITCHTIP_DSN=https://abc123@glitchtip.yourcompany.com/1
GLITCHTIP_SEND_IN_DEV=false  # Set to true to send errors in development
```

## How It Works

- The Sentry browser SDK (v8.46.0) is loaded via CDN from `https://browser.sentry-cdn.com/`
- SDK initializes only if `GLITCHTIP_DSN` environment variable is set
- Traces sampling is set to 1% (`tracesSampleRate: 0.01`)
- In development mode, errors are logged to console but NOT sent to GlitchTip (unless `GLITCHTIP_SEND_IN_DEV=true`)
- File upload errors are automatically captured via existing `window.Sentry.captureException()` calls

## Testing

To verify the integration is working:

1. Set `GLITCHTIP_DSN` environment variable
2. Start your Rails server
3. Open browser DevTools console
4. Check for Sentry initialization message
5. Verify `window.Sentry` is available: `console.log(window.Sentry)`

To test error reporting:
```javascript
// Run in browser console
window.Sentry.captureException(new Error("Test error from console"));
```

## Documentation

- GlitchTip JavaScript SDK: https://glitchtip.com/sdkdocs/javascript/
- Sentry Browser SDK: https://docs.sentry.io/platforms/javascript/

## Security Notes

- The DSN is public and safe to expose in client-side code
- GlitchTip/Sentry SDKs are designed to be used client-side
- The DSN only allows sending events, not reading or modifying data
- Consider setting up rate limiting in GlitchTip project settings
