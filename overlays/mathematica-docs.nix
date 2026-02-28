self: super: {
  mathematica = super.mathematica.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.rsync ];
    installPhase = ''
      runHook preInstall

      cd "$TMPDIR/Unix/Installer"

      mkdir -p "$out/lib/udev/rules.d"

      # Set name of installer file
      if [ -f "MathInstaller" ]; then
        INSTALLER="MathInstaller"
      else
        INSTALLER="WolframInstaller"
      fi
      # Patch Installer's shebangs and udev rules dir
      patchShebangs $INSTALLER
      substituteInPlace $INSTALLER \
        --replace /etc/udev/rules.d $out/lib/udev/rules.d

      # Remove PATH restriction, root and avahi daemon checks, hostname call, and installBundledInstall
      sed -i '
        s/^\s*PATH=/# &/
        s/isRoot="false"/# &/
        s/^\s*checkAvahiDaemon$/:/
        s/^\s*installBundledInstall$/:/
        s/`hostname`/""/
      ' $INSTALLER

      # Run installer without bundled documentation
      XDG_DATA_HOME="$out/share" HOME="$TMPDIR/home" vernierLink=y \
        ./$INSTALLER -execdir="$out/bin" -targetdir="$out/libexec/Mathematica" -auto -verbose -createdir=y

      # Check if Installer produced any errors
      errLog="$out/libexec/Mathematica/InstallErrors"
      if [ -f "$errLog" ]; then
        echo "Installation errors:"
        cat "$errLog"
        return 1
      fi

      # Manually extract and install bundled documentation
      # Similar to Arch Linux PKGBUILD approach
      if [ -d "$TMPDIR/Unix/.bundle" ]; then
        echo "Extracting bundled documentation..."
        cd "$TMPDIR/Unix/.bundle/Unix/Installer"

        # Run MathInstaller to extract documentation to temp location
        if [ -f "MathInstaller" ]; then
          patchShebangs MathInstaller
          ./MathInstaller -targetdir="$TMPDIR/bundled" -auto -verbose -createdir=y || true
        fi

        # Copy documentation from extracted bundled files
        if [ -d "$TMPDIR/bundled/Documentation" ]; then
          echo "Copying bundled documentation..."
          rsync -a --remove-source-files "$TMPDIR/bundled/Documentation/" "$out/libexec/Mathematica/Documentation/"
        fi
      fi

      runHook postInstall
    '';
  });
}
