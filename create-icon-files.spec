Name:           create-icon-files
Version:        0.1.0
Release:        1%{?dist}
Summary:        Universal Icon Generator for Linux, Windows, macOS, and Mobile

License:        GPLv3+
URL:            https://github.com/steve-rock-wheelhouser/create-icon-files
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib
Requires:       hicolor-icon-theme

%description
A GUI tool to generate icon files for various platforms including Linux, Windows (.ico), macOS (.icns), Android, iOS, and Web.

%prep
%setup -q

%build
# Binary is already compiled and included in Source0

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libexecdir}/%{name}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_metainfodir}
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/256x256/apps

# Install Binary and Assets
install -m 755 create-icon-files.bin %{buildroot}%{_libexecdir}/%{name}/%{name}.bin
cp -r assets %{buildroot}%{_libexecdir}/%{name}/

# Install Wrapper Script
cat > %{buildroot}%{_bindir}/%{name} <<EOF
#!/bin/bash
export GTK_THEME=Adwaita:dark
export GTK_USE_PORTAL=1
export QT_QPA_PLATFORMTHEME=gtk3
exec %{_libexecdir}/%{name}/%{name}.bin "\$@"
EOF
chmod 755 %{buildroot}%{_bindir}/%{name}

# Install Desktop File & Metadata
install -m 644 com.wheelhouser.create_icon_files.desktop %{buildroot}%{_datadir}/applications/
install -m 644 com.wheelhouser.create_icon_files.metainfo.xml %{buildroot}%{_metainfodir}/

%files
%license LICENSE
%{_bindir}/%{name}
%{_libexecdir}/%{name}/
%{_datadir}/applications/*.desktop
%{_metainfodir}/*.xml

%changelog