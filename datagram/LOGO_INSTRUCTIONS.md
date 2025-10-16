# Datagram Logo Setup Instructions

## 📁 Directory Structure
```
datagram/
├── assets/
│   └── datagram-logo.png    # Add the Datagram logo here
├── README.md
├── deploy.yml
├── build.yml
├── docker-compose.yml
└── SUBMISSION_README.md
```

## 🎨 Logo Requirements
- **Format**: PNG (preferred) or SVG
- **Size**: At least 640×320 pixels (1280×640 recommended)
- **Background**: Transparent or white background
- **File name**: `datagram-logo.png`

## 📝 README.md Update
Add this to the top of `datagram/README.md`:

```markdown
# Datagram

![Datagram Logo](./assets/datagram-logo.png)

| Version | Binary | Directory | ENV namespace | Repository | Image |
|---------|--------|-----------|----------------|------------|-------|
| v1.1.4 | datagram | .datagram | DATAGRAM | https://github.com/VirgilBB/datagram-nodeops | virgilbb/datagram-node:amd64 |
```

## 🚀 Next Steps
1. Download the official Datagram logo
2. Save it as `datagram/assets/datagram-logo.png`
3. Update `datagram/README.md` with the logo reference
4. Commit and push the changes
