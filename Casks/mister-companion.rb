cask "mister-companion" do
  version "v4.3.0"
  sha256 :no_check

  url "https://github.com/Anime0t4ku/mister-companion.git",
      using: :git,
      tag: "#{version}"

  name "MiSTer Companion"
  desc "GUI utility for MiSTer FPGA (SSH + Offline SD mode)"
  homepage "https://github.com/Anime0t4ku/mister-companion"

  depends_on macos: ">= :ventura"
  depends_on formula: "python@3.12"

  installer script: {
    executable: "/usr/bin/env",
    args: [
      "bash", "-c",
      <<~EOS
        set -e
        cd "#{staged_path}"

        PYTHON="#{Formula["python@3.12"].opt_libexec}/bin/python"
        $PYTHON -m venv venv
        venv/bin/pip install --upgrade pip
        venv/bin/pip install -r mister-companion/requirements.txt

        # CLI wrapper
        cat > "#{staged_path}/mister-companion-wrapper" << 'EOF'
#!/bin/bash
exec "#{staged_path}/venv/bin/python" "#{staged_path}/mister-companion/main.py" "$@"
EOF
        chmod 0755 "#{staged_path}/mister-companion-wrapper"

        # Native .app with icon
        APP="#{staged_path}/MiSTer Companion.app"
        mkdir -p "$APP/Contents/MacOS"
        mkdir -p "$APP/Contents/Resources"

        cp "#{staged_path}/mister-companion/app.ico" "$APP/Contents/Resources/app.icns"

        cat > "$APP/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>com.Anime0t4ku.mistercompanion</string>
    <key>CFBundleName</key><string>MiSTer Companion</string>
    <key>CFBundleDisplayName</key><string>MiSTer Companion</string>
    <key>CFBundleExecutable</key><string>mister-companion</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>#{version.to_s.sub(/^v/, "")}</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>CFBundleIconFile</key><string>app.icns</string>
</dict>
</plist>
EOF

        cat > "$APP/Contents/MacOS/mister-companion" << 'EOF'
#!/bin/bash
cd "#{staged_path}"
exec "#{staged_path}/venv/bin/python" "#{staged_path}/mister-companion/main.py" "$@"
EOF
        chmod 0755 "$APP/Contents/MacOS/mister-companion"
      EOS
    ],
    print_stderr: true
  }

  binary "#{staged_path}/mister-companion-wrapper", target: "mister-companion"

  artifact "#{staged_path}/MiSTer Companion.app", target: "/Applications/MiSTer Companion.app"

  zap trash: [
    "~/Library/Application Support/mister-companion",
    "~/Library/Preferences/com.Anime0t4ku.mistercompanion*",
    "~/Library/Saved Application State/com.Anime0t4ku.mistercompanion*"
  ]
end