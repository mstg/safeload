# safeload
even better crash handler for opee

# Installation
```
Build safeload
Place in /Library/Opee/Extensions
Make /usr/local writeable to $USER
  chown -R $USER /usr/local
  chmod -R 755 /usr/local
```

**Currently only works with my fork of [Opee](https://github.com/mstg/Opee)**

# Why
Saves you from trouble while developing, it disables Opee until next launch for the crashing process (Specially useful for system processes, Eg. Dock)
