# 🔐 Security Code Review Checklist

**For Development Team - Use before committing security-sensitive code**

---

## Pre-Commit Security Checklist

### Cryptography & Random Numbers
- [ ] No `java.util.Random()` usage - must use `java.security.SecureRandom`
- [ ] No `Math.random()` usage for security purposes
- [ ] All sensitive tokens/keys use cryptographically secure generation
- [ ] No hard-coded encryption keys or API keys

### Data Storage & Transmission
- [ ] Sensitive data encrypted before storage
- [ ] All network calls use HTTPS (no cleartext traffic)
- [ ] No sensitive data in SharedPreferences without encryption
- [ ] No sensitive data in database without encryption
- [ ] Request bodies don't contain sensitive data in logs

### Screen & Memory Security
- [ ] FLAG_SECURE set for screens with sensitive data ✅ (Already implemented in MainActivity)
- [ ] Password fields use `android:inputType="textPassword"`
- [ ] Sensitive data cleared from memory after use
- [ ] No sensitive data in app screenshots/previews

### Authentication & Authorization
- [ ] User tokens stored securely
- [ ] Token expiration properly handled
- [ ] No plain-text password storage
- [ ] Proper session management
- [ ] Rate limiting on authentication endpoints

### Permissions
- [ ] Only requested permissions are used
- [ ] Runtime permissions requested appropriately
- [ ] Permission rationale explained to users
- [ ] Critical permissions cannot be bypassed

### Android Manifest
- [ ] `android:allowBackup="false"` ✅ (Already configured)
- [ ] No overly permissive exported components
- [ ] All activities/services have proper protection levels
- [ ] No unnecessary intent-filters
- [ ] Broadcast receivers properly protected

### Network Security
- [ ] Certificate pinning configured ✅ (Already in network_security_config)
- [ ] No deprecated SSL/TLS versions
- [ ] Domain validation properly implemented
- [ ] Man-in-the-middle protection enabled

### Code Obfuscation
- [ ] ProGuard minification enabled for release ✅ (Already configured)
- [ ] ProGuard rules updated for new custom classes
- [ ] All new services/receivers added to keep rules if needed
- [ ] Build tested with obfuscation before commit

### Logging
- [ ] No sensitive data in logs
- [ ] Debug logging disabled for production
- [ ] Logging statements use appropriate levels
- [ ] No stack traces exposed to users

### Third-Party Dependencies
- [ ] No known vulnerabilities in new dependencies
- [ ] Dependency versions pinned or constrained
- [ ] No unnecessary dependencies added
- [ ] Dependencies updated before release

---

## Code Patterns to Avoid

### ❌ WRONG - Weak Random
```kotlin
val secret = Random().nextLong()
val rand = java.util.Random()
val number = Math.random()
```

### ✅ CORRECT - Secure Random
```kotlin
import java.security.SecureRandom
val secureRandom = SecureRandom()
val secret = secureRandom.nextLong()
```

### ❌ WRONG - Plain-text Password
```kotlin
val password = editText.text.toString()
println("User password: $password")  // EXPOSED!
```

### ✅ CORRECT - Secure Handling
```kotlin
val password = editText.text
// Immediately clear the input field
editText.text.clear()
// Never log passwords
// Use immediately and clear from memory
```

### ❌ WRONG - Hardcoded Credentials
```kotlin
const val API_KEY = "sk_live_abc123xyz"
val password = "admin123"
```

### ✅ CORRECT - Environment-based Secrets
```kotlin
// Use BuildConfig or secure configuration
val apiKey = BuildConfig.API_KEY  // From build config
// Or use secure storage: EncryptedSharedPreferences
```

### ❌ WRONG - No HTTPS
```kotlin
val url = "http://api.example.com/data"
```

### ✅ CORRECT - Always HTTPS
```kotlin
val url = "https://api.example.com/data"
```

---

## Testing Checklist

### Before Submitting PR

- [ ] **Unit Tests**
  - [ ] Security-related logic has unit tests
  - [ ] Edge cases covered
  - [ ] All tests pass

- [ ] **Integration Tests**
  - [ ] API calls work correctly
  - [ ] Authentication flow works
  - [ ] Data persistence works

- [ ] **Manual Testing**
  - [ ] Built with `flutter build apk --release`
  - [ ] App runs without crashes
  - [ ] All features work correctly
  - [ ] No sensitive data in logcat
  - [ ] No unhandled exceptions

- [ ] **Security Testing**
  - [ ] Attempted to decompile APK (code is obfuscated)
  - [ ] Verified FLAG_SECURE is active (screen can't be recorded)
  - [ ] Checked that backups are disabled
  - [ ] Verified no hardcoded secrets in code

---

## Review Questions

**For Security-Sensitive Code Changes:**

1. **What data is being handled?**
   - Is it personally identifiable?
   - Is it financially sensitive?
   - Is it user authentication data?

2. **How is it stored?**
   - Encrypted? Plain-text?
   - In SharedPreferences, Database, or Memory?
   - Can it be extracted via backup?

3. **How is it transmitted?**
   - HTTPS only?
   - Certificate pinning?
   - Validated on both ends?

4. **Who can access it?**
   - Only the app?
   - Other apps?
   - The device user?
   - Attackers with device access?

5. **What could go wrong?**
   - Reverse engineering exposure?
   - Network interception?
   - Local storage exposure?
   - Incorrect permission checks?

6. **How is it tested?**
   - Unit tests?
   - Integration tests?
   - Manual security testing?

---

## Commit Message Template

```
[SECURITY] {Fix/Feature} - {Description}

Type: {Critical/High/Medium/Low}

Changes:
- {Change 1}
- {Change 2}

Testing:
- {Test 1}
- {Test 2}

Checklist:
- [x] Code follows security guidelines
- [x] No hardcoded secrets
- [x] No sensitive data in logs
- [x] ProGuard rules updated (if needed)
- [x] All tests passing
- [x] Code reviewed by: {Name}

Fixes: #{Issue number}
```

**Example:**
```
[SECURITY] Fix - Replace weak random with SecureRandom

Type: High

Changes:
- Replaced Math.random() with SecureRandom in TokenGenerator
- Added unit tests for secure random generation
- Updated ProGuard rules for new security library

Testing:
- Unit tests: 5 new tests, all passing
- Manual: Verified no weak random in release APK

Checklist:
- [x] Code follows security guidelines
- [x] No hardcoded secrets
- [x] ProGuard rules updated
- [x] All tests passing
- [x] Code reviewed by: John Doe

Fixes: #234
```

---

## ProGuard Rules Update Guide

**When to update ProGuard rules:**

1. **Adding new custom classes:**
```proguard
-keep class com.example.uje.myfeature.** { *; }
```

2. **Adding new services:**
```proguard
-keep class com.example.uje.services.MyService { *; }
-keep class com.example.uje.services.MyService$* { *; }
```

3. **Adding new models/entities:**
```proguard
-keep class com.example.uje.model.User { *; }
-keep class com.example.uje.model.Transaction { *; }
```

4. **If keeping specific methods:**
```proguard
-keep class com.example.uje.Utils {
    public static java.lang.String encrypt(...);
    public static java.lang.String decrypt(...);
}
```

5. **After adding new dependencies, test:**
```bash
flutter build apk --release
# Then decompile and verify code is still obfuscated
```

---

## Emergency Procedures

### If Hardcoded Secret Found
1. **Immediately:**
   - Remove the secret from code
   - Rotate the secret on server side
   - Revoke access tokens if exposed

2. **Notify:**
   - Security team
   - Affected users (if applicable)
   - App store (if already released)

3. **Release:**
   - Build new version with removed secret
   - Submit to app store ASAP
   - Push notification to users to update

### If Security Vulnerability Discovered
1. **Assess:**
   - Severity level
   - Attack vectors
   - Affected users

2. **Fix:**
   - Implement security patch
   - Thoroughly test
   - Get security review

3. **Release:**
   - Priority release to app store
   - Notify users
   - Monitor for exploitation

---

## Additional Resources

- [Android Security Best Practices](https://developer.android.com/topic/security)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Guide](https://flutter.dev/docs/security)
- [ProGuard Manual](https://www.guardsquare.com/proguard/manual)
- [Android Developers Security](https://developer.android.com/privacy-and-security)

---

**Last Updated:** May 13, 2026  
**Review Frequency:** Quarterly or as needed  
**Maintained By:** Security Team

