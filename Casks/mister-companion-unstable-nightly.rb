cask "mister-companion-unstable-nightly" do
  version "0.0.1"
  sha256 :no_check

    url "https://github.com/Anime0t4ku/mister-companion.git",
      using: :git,
      branch: "main"

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
        cat > "#{staged_path}/mister-companion-unstable-nightly-wrapper" << 'EOF'
#!/bin/bash
exec "#{staged_path}/venv/bin/python" "#{staged_path}/mister-companion/main.py" "$@"
EOF
        chmod 0755 "#{staged_path}/mister-companion-unstable-nightly-wrapper"

        # Native .app with icon
        APP="#{staged_path}/MiSTer Companion Unstable Nightly.app"
        mkdir -p "$APP/Contents/MacOS"
        mkdir -p "$APP/Contents/Resources"

        cp "#{staged_path}/mister-companion/app.ico" "$APP/Contents/Resources/app.icns"

        cat > "$APP/Contents/Info.plist" << 'PLIST'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleIdentifier</key><string>com.Anime0t4ku.mistercompanion-unstable-nightly</string>
      <key>CFBundleName</key><string>MiSTer Companion Unstable Nightly</string>
      <key>CFBundleDisplayName</key><string>MiSTer Companion Unstable Nightly</string>
      <key>CFBundleExecutable</key><string>mister-companion-unstable-nightly</string>
      <key>CFBundlePackageType</key><string>APPL</string>
      <key>CFBundleShortVersionString</key><string>#{version}</string>
      <key>LSMinimumSystemVersion</key><string>13.0</string>
      <key>NSHighResolutionCapable</key><true/>
      <key>CFBundleIconFile</key><string>app.icns</string>
    </dict>
    </plist>
    PLIST

        cat > "$APP/Contents/MacOS/mister-companion-unstable-nightly" << 'LAUNCHER'
#!/bin/bash
cd "#{staged_path}"
exec "#{staged_path}/venv/bin/python" "#{staged_path}/mister-companion/main.py" "$@"
LAUNCHER
        chmod 0755 "$APP/Contents/MacOS/mister-companion-unstable-nightly"
      EOS
    ],
    print_stderr: true
  }

  binary "#{staged_path}/mister-companion-unstable-nightly-wrapper", target: "mister-companion-unstable-nightly"

  artifact "#{staged_path}/MiSTer Companion Unstable Nightly.app", target: "/Applications/MiSTer Companion Unstable Nightly.app"

  zap trash: [
    "~/Library/Application Support/mister-companion-unstable-nightly",
    "~/Library/Preferences/com.Anime0t4ku.mistercompanion-unstable-nightly*",
    "~/Library/Saved Application State/com.Anime0t4ku.mistercompanion-unstable-nightly*"
  ]
end