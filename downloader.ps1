# =================================================================
# CINNAMON EDITION (THE ULTIMATE MASTERPIECE)
# + [UPDATE]: Auto-Download Backsound via YT-DLP & Simpan Status Mute
# + [UPDATE]: Auto-Update Script dari GitHub
# =================================================================

# -----------------------------------------------------------------
# PENGATURAN VERSI & GITHUB (UBAH BAGIAN INI SAAT UPDATE!)
# -----------------------------------------------------------------
$global:AppVersion = 18.1
$global:UpdateUrl  = "https://raw.githubusercontent.com/jeco2012/youtube-downloader-pro-by-jackport_game/refs/heads/main/downloader.ps1"
# -----------------------------------------------------------------

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor 3072

if ($PSScriptRoot) { Set-Location -Path $PSScriptRoot }

# ANTI-THROTTLE / CEGAH PC SLEEP
Add-Type -AssemblyName PresentationFramework, WindowsBase, System.Xaml
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class Win32 {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
    public const uint ES_CONTINUOUS = 0x80000000;
    public const uint ES_SYSTEM_REQUIRED = 0x00000001;
}
"@

# DESAIN DESKTOP GUI (XAML)
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="YouTube Multi-Downloader Dashboard - Masterpiece" Height="980" Width="850" 
        Background="{DynamicResource BgBrush}" WindowStartupLocation="CenterScreen">
    
        <Window.Resources>
        <SolidColorBrush x:Key="BgBrush" Color="#121212"/>
        <SolidColorBrush x:Key="FgBrush" Color="#ffffff"/>
        <SolidColorBrush x:Key="MutedFgBrush" Color="#cccccc"/>
        <SolidColorBrush x:Key="BoxBgBrush" Color="#1e1e1e"/>
        <SolidColorBrush x:Key="BorderBrush" Color="#444444"/>
        <SolidColorBrush x:Key="PanelBgBrush" Color="#1a1a1a"/>
        <SolidColorBrush x:Key="LogBgBrush" Color="#050505"/>
        <SolidColorBrush x:Key="CyanAccent" Color="#00ffff"/>
        
        <SolidColorBrush x:Key="{x:Static SystemColors.WindowBrushKey}" Color="#1e1e1e"/>
        <SolidColorBrush x:Key="{x:Static SystemColors.WindowTextBrushKey}" Color="#ffffff"/>
        <SolidColorBrush x:Key="{x:Static SystemColors.HighlightBrushKey}" Color="#87cf3e"/>
        <SolidColorBrush x:Key="{x:Static SystemColors.HighlightTextBrushKey}" Color="#121212"/>
        <SolidColorBrush x:Key="{x:Static SystemColors.ControlTextBrushKey}" Color="#ffffff"/>

        <Style TargetType="Button">
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" 
                                BorderBrush="{TemplateBinding BorderBrush}" 
                                BorderThickness="{TemplateBinding BorderThickness}" 
                                CornerRadius="5">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Opacity" Value="0.85"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        
        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="#333333"/>
            <Setter Property="Foreground" Value="#ffffff"/>
            <Setter Property="BorderBrush" Value="{DynamicResource BorderBrush}"/>
            <Setter Property="Padding" Value="4"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
        </Style>
        
        <Style TargetType="ComboBoxItem">
            <Setter Property="Background" Value="#333333"/>
            <Setter Property="Foreground" Value="#ffffff"/>
            <Setter Property="Padding" Value="5"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#87cf3e"/> 
                    <Setter Property="Foreground" Value="#121212"/>
                </Trigger>
                <Trigger Property="IsSelected" Value="True">
                    <Setter Property="Background" Value="#ffb627"/> 
                    <Setter Property="Foreground" Value="#121212"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>
    
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>   
            <RowDefinition Height="Auto"/>   
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- OVERLAY PENGATURAN & TUTORIAL -->
        <Grid Name="GridOverlay" Grid.RowSpan="10" Background="#A8000000" Visibility="Collapsed" Panel.ZIndex="100">
            <!-- PENGATURAN PANEL -->
            <Border Name="PanelSettings" Background="{DynamicResource BgBrush}" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="1" CornerRadius="8" Width="420" Height="280" HorizontalAlignment="Center" VerticalAlignment="Center" Padding="25" Visibility="Collapsed">
                <StackPanel>
                    <TextBlock Text="⚙️ PENGATURAN SISTEM" FontSize="18" FontWeight="Bold" Foreground="{DynamicResource FgBrush}" HorizontalAlignment="Center" Margin="0,0,0,20"/>
                    <TextBlock Text="Pilih Tema Tampilan (Auto-Save):" Foreground="{DynamicResource MutedFgBrush}" Margin="0,0,0,5"/>
                    <ComboBox Name="CboTheme" SelectedIndex="2" Margin="0,0,0,20">
                        <ComboBoxItem Content="🌙 Dark Mode (Gelap)"/>
                        <ComboBoxItem Content="☀️ Light Mode (Terang)"/>
                        <ComboBoxItem Content="🖥️ Auto (Ikuti Sistem Web/Windows)"/>
                    </ComboBox>
                    <TextBlock Text="Manajemen Cache Mesin:" Foreground="{DynamicResource MutedFgBrush}" Margin="0,0,0,5"/>
                    <Button Name="BtnClearCache" Content="🗑️ HAPUS CACHE YT-DLP" Background="#ffb627" Foreground="#121212" FontWeight="Bold" Height="35" Margin="0,0,0,25" Cursor="Hand" ToolTip="Gunakan ini jika unduhan sering gagal atau stuck"/>
                    <Button Name="BtnCloseSettings" Content="TUTUP &amp; SIMPAN PENGATURAN" Background="#d9534f" Foreground="#ffffff" FontWeight="Bold" Height="35" Cursor="Hand"/>
                </StackPanel>
            </Border>

            <!-- TUTORIAL PANEL -->
            <Border Name="PanelTutorial" Background="{DynamicResource BgBrush}" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="1" CornerRadius="8" Width="550" Height="400" HorizontalAlignment="Center" VerticalAlignment="Center" Padding="20" Visibility="Collapsed">
                <StackPanel>
                    <TextBlock Text="❓ TUTORIAL SINGKAT PENGGUNAAN" FontSize="18" FontWeight="Bold" Foreground="#87cf3e" HorizontalAlignment="Center" Margin="0,0,0,15"/>
                    <TextBox Background="{DynamicResource BoxBgBrush}" Foreground="{DynamicResource FgBrush}" BorderThickness="1" BorderBrush="{DynamicResource BorderBrush}" IsReadOnly="True" TextWrapping="Wrap" Height="260" ScrollViewer.VerticalScrollBarVisibility="Auto" Margin="0,0,0,15" Padding="10" 
Text="Selamat datang di YouTube Downloader Pro!&#x0a;&#x0a;Langkah Mudah Mengunduh:&#x0a;1. Masukkan baris Link YouTube di kotak utama. Bisa masukkan banyak link sekaligus (enter ke bawah).&#x0a;2. Pilih 'Folder Target Penyimpanan' untuk menentukan lokasi output.&#x0a;3. Pilih Mode: Ingin mendownload Video atau sekadar Ekstrak Audio (MP3/WAV).&#x0a;4. Tentukan Resolusi Kualitas, Dubbing Bahasa, dan Subtitle sesuai kebutuhan.&#x0a;5. Klik tombol hijau 'MULAI PROSES SEKARANG'.&#x0a;&#x0a;Catatan Penting:&#x0a;🟢 Jika video terkunci usia, centang 'Bypass Cookie' dan pilih Browser yang biasa Anda gunakan. Pastikan browser dalam keadaan TERTUTUP saat proses berlangsung!&#x0a;🟢 Centang 'Smart Save' agar setiap perubahan konfigurasi Anda tersimpan otomatis."/>
                    <Button Name="BtnCloseTutorial" Content="SAYA MENGERTI" Background="#87cf3e" Foreground="#121212" FontWeight="Bold" Height="35" Cursor="Hand"/>
                </StackPanel>
            </Border>
        </Grid>

        <!-- HEADER -->
        <Grid Grid.Row="0" Margin="0,0,0,15">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <StackPanel Grid.Column="0">
                <TextBlock Text="🎬 YouTube Downloader Pro" FontSize="26" FontWeight="Bold" Foreground="#87cf3e"/>
                <TextBlock Name="TxtSubTitle" Text="Cinnamon Edition" FontSize="12" Foreground="{DynamicResource MutedFgBrush}" Margin="2,0,0,0"/>
            </StackPanel>
            
            <Button Name="BtnMusic" Grid.Column="1" Content="🔊" FontSize="22" Background="Transparent" Foreground="{DynamicResource FgBrush}" BorderThickness="0" Margin="0,0,5,0" Cursor="Hand" ToolTip="Mute/Unmute Backsound"/>
            <Button Name="BtnHelp" Grid.Column="2" Content="❓" FontSize="22" Background="Transparent" Foreground="{DynamicResource FgBrush}" BorderThickness="0" Margin="0,0,5,0" Cursor="Hand" ToolTip="Tutorial Singkat"/>
            <Button Name="BtnSettings" Grid.Column="3" Content="⚙️" FontSize="22" Background="Transparent" Foreground="{DynamicResource FgBrush}" BorderThickness="0" Cursor="Hand" ToolTip="Pengaturan"/>
        </Grid>

        <!-- LINK INPUT -->
        <StackPanel Grid.Row="1" Margin="0,0,0,15">
            <TextBlock Text="Masukkan Baris Link YouTube:" Foreground="{DynamicResource FgBrush}" Margin="0,0,0,5" FontSize="13"/>
            <TextBox Name="TxtLinks" Height="80" Background="{DynamicResource BoxBgBrush}" Foreground="{DynamicResource FgBrush}" 
                     BorderBrush="{DynamicResource BorderBrush}" BorderThickness="1.5" VerticalScrollBarVisibility="Auto" 
                     AcceptsReturn="True" TextWrapping="Wrap" Padding="6" FontSize="12"/>
        </StackPanel>

        <!-- FOLDER TARGET -->
        <StackPanel Grid.Row="2" Margin="0,0,0,15">
            <TextBlock Text="📂 Folder Target Output Penyimpanan:" Foreground="{DynamicResource FgBrush}" Margin="0,0,0,5" FontSize="13"/>
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBox Name="TxtPath" Grid.Column="0" Height="32" Background="{DynamicResource BoxBgBrush}" Foreground="{DynamicResource MutedFgBrush}" 
                         BorderBrush="{DynamicResource BorderBrush}" BorderThickness="1" Padding="5" FontSize="12" IsReadOnly="True"/>
                <Button Name="BtnBrowse" Grid.Column="1" Content="BROWSE FOLDER" Background="#ffb627" Foreground="#121212" 
                        FontWeight="Bold" Width="130" Margin="5,0,0,0" Cursor="Hand"/>
            </Grid>
        </StackPanel>

        <!-- PILIH MODE -->
        <Border Grid.Row="3" Background="{DynamicResource PanelBgBrush}" CornerRadius="5" Padding="10" Margin="0,0,0,15" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="1">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                <TextBlock Text="🎯 PILIH MODE UTAMA:" Foreground="{DynamicResource FgBrush}" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,20,0" FontSize="13"/>
                <RadioButton Name="RadVideo" GroupName="ModeUtama" Content="🎬 VIDEO MODERASI" Foreground="#ffb627" FontWeight="Bold" FontSize="13" IsChecked="True" Margin="0,0,30,0" Cursor="Hand"/>
                <RadioButton Name="RadAudio" GroupName="ModeUtama" Content="🎧 EKSTRAK AUDIO (MP3/WAV)" Foreground="{DynamicResource CyanAccent}" FontWeight="Bold" FontSize="13" Cursor="Hand"/>
            </StackPanel>
        </Border>

        <!-- CONFIG BOX -->
        <Grid Grid.Row="4" Margin="0,0,0,15">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1*"/>
                <ColumnDefinition Width="15"/>
                <ColumnDefinition Width="1*"/>
            </Grid.ColumnDefinitions>

            <GroupBox Name="GrpVideo" Grid.Column="0" Header="🎬 FORMAT CONFIG VIDEO" Foreground="#ffb627" FontWeight="Bold" BorderBrush="{DynamicResource BorderBrush}" Padding="10">
                <StackPanel>
                    <TextBlock Text="Kualitas Resolusi Maksimal (-f):" Foreground="{DynamicResource MutedFgBrush}" Margin="0,5,0,3"/>
                    <ComboBox Name="CboVidRes" SelectedIndex="3">
                        <ComboBoxItem Content="👑 4320p (8K Ultra HD)"/>
                        <ComboBoxItem Content="👑 2160p (4K Ultra HD)"/>
                        <ComboBoxItem Content="🎬 1440p (2K Quad HD)"/>
                        <ComboBoxItem Content="🎥 1080p (Full HD - Rekomendasi)"/>
                        <ComboBoxItem Content="📺 720p (HD - Hemat Bandwidth)"/>
                        <ComboBoxItem Content="📱 480p (SD Standar)"/>
                        <ComboBoxItem Content="📼 360p (Rendah)"/>
                    </ComboBox>
                    <TextBlock Text="Format Gabungan Muxing:" Foreground="{DynamicResource MutedFgBrush}" Margin="0,8,0,3"/>
                    <ComboBox Name="CboVidFmt" SelectedIndex="0">
                        <ComboBoxItem Content="MP4 (Paling Kompatibel &amp; Aman)"/>
                        <ComboBoxItem Content="MKV (Kualitas Lossless Kontainer)"/>
                        <ComboBoxItem Content="WEBM (Format Ringan Web)"/>
                        <ComboBoxItem Content="AVI (Klasik Legacy)"/>
                    </ComboBox>
                </StackPanel>
            </GroupBox>

            <GroupBox Name="GrpAudio" Grid.Column="2" Header="🎧 AUDIO CONVERT CONFIG" Foreground="{DynamicResource CyanAccent}" FontWeight="Bold" BorderBrush="{DynamicResource BorderBrush}" Padding="10" Opacity="0.35" IsHitTestVisible="False">
                <StackPanel>
                    <TextBlock Text="Ekstensi Format Audio (-x):" Foreground="{DynamicResource MutedFgBrush}" Margin="0,5,0,3"/>
                    <ComboBox Name="CboAudFmt" SelectedIndex="0">
                        <ComboBoxItem Content="MP3 (Kompresi Populer)"/>
                        <ComboBoxItem Content="WAV (Mentah / Uncompressed PCM)"/>
                        <ComboBoxItem Content="FLAC (Audiophile Lossless)"/>
                        <ComboBoxItem Content="M4A (Standar Apple AAC)"/>
                        <ComboBoxItem Content="OGG (Vorbis Berkualitas)"/>
                    </ComboBox>
                    <TextBlock Text="Kompresi Bitrate Audio:" Foreground="{DynamicResource MutedFgBrush}" Margin="0,8,0,3"/>
                    <ComboBox Name="CboAudBit" SelectedIndex="0">
                        <ComboBoxItem Content="320 Kbps (Sangat Jernih)"/>
                        <ComboBoxItem Content="256 Kbps (Bagus Sekali)"/>
                        <ComboBoxItem Content="192 Kbps (Normal)"/>
                        <ComboBoxItem Content="128 Kbps (Hemat Storage)"/>
                    </ComboBox>
                </StackPanel>
            </GroupBox>
        </Grid>

        <!-- EXTRA OPTION -->
        <WrapPanel Grid.Row="5" Margin="0,0,0,15">
            <CheckBox Name="ChkSmartMode" Content="🧠 Smart Save" Foreground="#87cf3e" FontWeight="Bold" Margin="0,0,15,8" VerticalAlignment="Center" IsChecked="True"/>
            <CheckBox Name="ChkPlaylist" Content="Unduh Semua Playlist" Foreground="{DynamicResource FgBrush}" Margin="0,0,15,8" VerticalAlignment="Center" IsChecked="False"/>
            
            <StackPanel Orientation="Horizontal" Margin="0,0,15,8" VerticalAlignment="Center">
                <TextBlock Text="🗣️ Dubbing:" Foreground="#ffb627" FontWeight="Bold" Margin="0,0,5,0" VerticalAlignment="Center"/>
                <ComboBox Name="CboDubbing" Width="105" SelectedIndex="0">
                    <ComboBoxItem Content="Default Asli"/>
                    <ComboBoxItem Content="Semua (All)"/>
                    <ComboBoxItem Content="🇮🇩 Indo (id)"/>
                    <ComboBoxItem Content="🇺🇸 Eng (en)"/>
                    <ComboBoxItem Content="🇨🇳 China (zh)"/>
                </ComboBox>
            </StackPanel>
            
            <StackPanel Orientation="Horizontal" Margin="0,0,15,8" VerticalAlignment="Center">
                <TextBlock Text="📝 Subtitle:" Foreground="{DynamicResource CyanAccent}" FontWeight="Bold" Margin="0,0,5,0" VerticalAlignment="Center"/>
                <ComboBox Name="CboSubtitle" Width="105" SelectedIndex="0">
                    <ComboBoxItem Content="Semua (All)"/>
                    <ComboBoxItem Content="🇮🇩 Indo (id)"/>
                    <ComboBoxItem Content="🇺🇸 Eng (en)"/>
                    <ComboBoxItem Content="❌ Matikan"/>
                </ComboBox>
            </StackPanel>
            
            <StackPanel Orientation="Horizontal" Margin="0,0,15,8" VerticalAlignment="Center">
                <CheckBox Name="ChkCookies" Content="🍪 Bypass Cookie:" Foreground="#ffb627" FontWeight="Bold" Margin="0,0,5,0" VerticalAlignment="Center" IsChecked="True"/>
                <ComboBox Name="CboBrowser" Width="85" SelectedIndex="0">
                    <ComboBoxItem Content="Chrome"/>
                    <ComboBoxItem Content="Edge"/>
                    <ComboBoxItem Content="Firefox"/>
                    <ComboBoxItem Content="Brave"/>
                </ComboBox>
            </StackPanel>
            
            <CheckBox Name="ChkForce" Content="⚡ Multi-Threading" Foreground="#ff5555" FontWeight="Bold" Margin="0,0,15,8" VerticalAlignment="Center" IsChecked="True"/>
            <CheckBox Name="ChkKeepVideo" Content="💾 Simpan Asli (-k)" Foreground="#ffaa00" FontWeight="SemiBold" Margin="0,0,15,8" VerticalAlignment="Center" IsChecked="False"/>
            <CheckBox Name="ChkShutdown" Content="🛌 AutoPC-Shutdown" Foreground="#ff8888" Margin="0,0,0,8" VerticalAlignment="Center"/>
        </WrapPanel>

        <!-- STATUS BAR -->
        <Border Grid.Row="6" Background="{DynamicResource LogBgBrush}" BorderBrush="{DynamicResource BorderBrush}" BorderThickness="1" CornerRadius="6" Padding="12" Margin="0,0,0,15">
            <UniformGrid Columns="4">
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="🚦 STATUS MESIN" FontSize="11" Foreground="{DynamicResource MutedFgBrush}" HorizontalAlignment="Center"/>
                    <TextBlock Name="StatStatus" Text="🟢 STANDBY" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource CyanAccent}" Margin="0,4,0,0" TextAlignment="Center"/>
                </StackPanel>
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="🎯 ANTRIAN PLAYLIST" FontSize="11" Foreground="{DynamicResource MutedFgBrush}" HorizontalAlignment="Center"/>
                    <TextBlock Name="StatQueue" Text="0 / 0" FontSize="14" FontWeight="Bold" Foreground="{DynamicResource FgBrush}" Margin="0,4,0,0"/>
                </StackPanel>
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="⚡ SPEED UNDUH" FontSize="11" Foreground="{DynamicResource MutedFgBrush}" HorizontalAlignment="Center"/>
                    <TextBlock Name="StatSpeed" Text="0.00 MB/s" FontSize="14" FontWeight="Bold" Foreground="#87cf3e" Margin="0,4,0,0"/>
                </StackPanel>
                <StackPanel HorizontalAlignment="Center">
                    <TextBlock Text="⏳ SISA WAKTU (ETA)" FontSize="11" Foreground="{DynamicResource MutedFgBrush}" HorizontalAlignment="Center"/>
                    <TextBlock Name="StatETA" Text="0m 0d" FontSize="14" FontWeight="Bold" Foreground="#ffb627" Margin="0,4,0,0" TextAlignment="Center"/>
                </StackPanel>
            </UniformGrid>
        </Border>

        <!-- BUTTONS ACTION -->
        <Grid Grid.Row="7" Margin="0,0,0,12">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="1.2*"/>
                <ColumnDefinition Width="1*"/>
                <ColumnDefinition Width="1*"/>
                <ColumnDefinition Width="1*"/>
                <ColumnDefinition Width="1*"/>
                <ColumnDefinition Width="1*"/>
            </Grid.ColumnDefinitions>
            
            <Button Name="BtnDownload" Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3" Content="🚀 MULAI PROSES SEKARANG" Background="#87cf3e" Foreground="#121212" FontSize="14" FontWeight="Bold" Height="45" Margin="0,0,5,8" Cursor="Hand"/>
            <Button Name="BtnCancel" Grid.Row="0" Grid.Column="3" Grid.ColumnSpan="3" Content="🛑 BATALKAN PROSES" Background="#d9534f" Foreground="#ffffff" FontSize="14" FontWeight="Bold" Height="45" Margin="0,0,0,8" Cursor="Hand" Opacity="0.3" IsHitTestVisible="False"/>
            
            <Button Name="BtnListFormats" Grid.Row="1" Grid.Column="0" Content="📋 CEK FORMAT" Background="{DynamicResource PanelBgBrush}" Foreground="{DynamicResource CyanAccent}" BorderBrush="{DynamicResource BorderBrush}" FontWeight="SemiBold" Height="38" Margin="0,0,5,0" Cursor="Hand"/>
            <Button Name="BtnUpdate" Grid.Row="1" Grid.Column="1" Content="🔄 UPDATE ENGINE" Background="{DynamicResource PanelBgBrush}" Foreground="#87cf3e" BorderBrush="{DynamicResource BorderBrush}" Height="38" Margin="0,0,5,0" Cursor="Hand"/>
            <Button Name="BtnHistory" Grid.Row="1" Grid.Column="2" Content="📜 CEK HISTORY" Background="{DynamicResource PanelBgBrush}" Foreground="#ffb627" BorderBrush="{DynamicResource BorderBrush}" Height="38" Margin="0,0,5,0" Cursor="Hand"/>
            <Button Name="BtnFolder" Grid.Row="1" Grid.Column="3" Content="📂 FOLDER SCRIPT" Background="{DynamicResource PanelBgBrush}" Foreground="{DynamicResource FgBrush}" BorderBrush="{DynamicResource BorderBrush}" Height="38" Margin="0,0,5,0" Cursor="Hand"/>
            <Button Name="BtnClear" Grid.Row="1" Grid.Column="4" Content="🗑️ REFRESH KOTAK" Background="{DynamicResource PanelBgBrush}" Foreground="{DynamicResource FgBrush}" BorderBrush="{DynamicResource BorderBrush}" Height="38" Margin="0,0,5,0" Cursor="Hand"/>
            <Button Name="BtnExit" Grid.Row="1" Grid.Column="5" Content="❌ KELUAR" Background="#ff3333" Foreground="#ffffff" FontWeight="Bold" Height="38" Margin="0,0,0,0" Cursor="Hand"/>
        </Grid>

        <StackPanel Grid.Row="8" Margin="0,0,0,5" VerticalAlignment="Stretch">
            <TextBlock Text="Console Log Aktivitas Mesin Internal:" Foreground="{DynamicResource FgBrush}" Margin="0,0,0,4" FontSize="12"/>
            <TextBox Name="TxtLog" Height="140" Background="{DynamicResource LogBgBrush}" Foreground="#a6e22e" 
                     BorderBrush="{DynamicResource BorderBrush}" IsReadOnly="True" VerticalScrollBarVisibility="Auto" 
                     TextWrapping="Wrap" Padding="8" FontFamily="Consolas" FontSize="11"/>
        </StackPanel>

        <TextBlock Grid.Row="9" Text="by jacksport_game &amp; kak gem 💚 - Masterpiece" 
                   HorizontalAlignment="Center" Foreground="{DynamicResource MutedFgBrush}" FontSize="11" FontStyle="Italic" Margin="0,5,0,0"/>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# SET WINDOW TITLE & SUBTITLE MENGGUNAKAN VARIABEL VERSION
$window.Title = "YouTube Multi-Downloader Dashboard - V$global:AppVersion Masterpiece"
$TxtSubTitle = $window.FindName("TxtSubTitle")
$TxtSubTitle.Text = "Cinnamon Edition v$global:AppVersion (Ultimate Masterpiece - Auto Update Supported)"

# ATTACH VARIABEL GUI
$TxtLinks     = $window.FindName("TxtLinks")
$TxtPath      = $window.FindName("TxtPath")
$BtnBrowse    = $window.FindName("BtnBrowse")
$RadVideo     = $window.FindName("RadVideo")
$RadAudio     = $window.FindName("RadAudio")
$CboVidRes    = $window.FindName("CboVidRes")
$CboVidFmt    = $window.FindName("CboVidFmt")
$CboAudFmt    = $window.FindName("CboAudFmt")
$CboAudBit    = $window.FindName("CboAudBit")
$GrpVideo     = $window.FindName("GrpVideo")
$GrpAudio     = $window.FindName("GrpAudio")
$ChkSmartMode = $window.FindName("ChkSmartMode")
$ChkPlaylist  = $window.FindName("ChkPlaylist")
$CboDubbing   = $window.FindName("CboDubbing")
$CboSubtitle  = $window.FindName("CboSubtitle")
$ChkCookies   = $window.FindName("ChkCookies")
$CboBrowser   = $window.FindName("CboBrowser")
$ChkForce     = $window.FindName("ChkForce")
$ChkKeepVideo = $window.FindName("ChkKeepVideo")
$ChkShutdown  = $window.FindName("ChkShutdown")

$BtnDownload    = $window.FindName("BtnDownload")
$BtnCancel      = $window.FindName("BtnCancel")
$BtnListFormats = $window.FindName("BtnListFormats")
$BtnUpdate      = $window.FindName("BtnUpdate")
$BtnHistory     = $window.FindName("BtnHistory")
$BtnFolder      = $window.FindName("BtnFolder")
$BtnClear       = $window.FindName("BtnClear")
$BtnExit        = $window.FindName("BtnExit")
$TxtLog         = $window.FindName("TxtLog")

$StatStatus  = $window.FindName("StatStatus")
$StatQueue   = $window.FindName("StatQueue")
$StatSpeed   = $window.FindName("StatSpeed")
$StatETA     = $window.FindName("StatETA")

# VARIABEL OVERLAY PENGATURAN, TUTORIAL & MUSIC
$BtnSettings      = $window.FindName("BtnSettings")
$BtnHelp          = $window.FindName("BtnHelp")
$BtnMusic         = $window.FindName("BtnMusic")
$GridOverlay      = $window.FindName("GridOverlay")
$PanelSettings    = $window.FindName("PanelSettings")
$PanelTutorial    = $window.FindName("PanelTutorial")
$CboTheme         = $window.FindName("CboTheme")
$BtnClearCache    = $window.FindName("BtnClearCache")
$BtnCloseSettings = $window.FindName("BtnCloseSettings")
$BtnCloseTutorial = $window.FindName("BtnCloseTutorial")

# BACKEND CONTROLLERS
$global:StatusMesin = "STANDBY"
$global:CancelRequested = $false
$global:PlaylistTotalItems = 0
$global:PlaylistCurrentItem = 0
$configFile = ".\cinnamon_config_pro.json"
$historyFile = ".\cinnamon_history_pro.txt"

# Inisialisasi Audio Engine Tersembunyi (WMP COM Object)
$global:wmp = New-Object -ComObject WMPlayer.OCX
$global:wmp.settings.setMode("loop", $true)
$global:wmp.settings.volume = 35 
$global:isMuted = $false

$TxtPath.Text = [Environment]::GetFolderPath("Myvideos")

$arrVidRes = @(4320, 2160, 1440, 1080, 720, 480, 360)
$arrVidFmt = @("mp4", "mkv", "webm", "avi")
$arrAudFmt = @("mp3", "wav", "flac", "m4a", "ogg")
$arrAudBit = @("320K", "256K", "192K", "128K")

# --- ENGINE TEMA SISTEM ---
function Set-AppTheme ($ThemeName) {
    $isLight = $false
    if ($ThemeName -eq "Auto") {
        try {
            $regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
            $val = (Get-ItemProperty -Path $regPath -Name "AppsUseLightTheme" -ErrorAction Stop).AppsUseLightTheme
            if ($val -eq 1) { $isLight = $true }
        } catch { $isLight = $false }
    } elseif ($ThemeName -match "Light") {
        $isLight = $true
    }

    if ($isLight) {
        $window.Resources["BgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#f5f6fa")
        $window.Resources["FgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#121212")
        $window.Resources["MutedFgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#555555")
        $window.Resources["BoxBgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#ffffff")
        $window.Resources["BorderBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#cccccc")
        $window.Resources["PanelBgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#e1e2e6")
        $window.Resources["LogBgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#e4e6eb")
        $window.Resources["CyanAccent"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#008888") 
        
        $window.Resources[[System.Windows.SystemColors]::WindowBrushKey] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#ffffff"))
        $window.Resources[[System.Windows.SystemColors]::WindowTextBrushKey] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#121212"))
    } else {
        $window.Resources["BgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#121212")
        $window.Resources["FgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#ffffff")
        $window.Resources["MutedFgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#cccccc")
        $window.Resources["BoxBgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1e1e1e")
        $window.Resources["BorderBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#444444")
        $window.Resources["PanelBgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1a1a1a")
        $window.Resources["LogBgBrush"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#050505")
        $window.Resources["CyanAccent"] = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#00ffff")
        
        $window.Resources[[System.Windows.SystemColors]::WindowBrushKey] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#222222"))
        $window.Resources[[System.Windows.SystemColors]::WindowTextBrushKey] = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#ffffff"))
    }
}

function Log-Msg ($pesan) {
    $TxtLog.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $pesan`r`n")
    $TxtLog.ScrollToEnd()
}

function Refresh-Dashboard {
    $window.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
}

function Ubah-Status-Tombol-Aksi ($bisaKlik) {
    if ($bisaKlik) {
        $BtnDownload.Opacity = 1.0; $BtnDownload.IsHitTestVisible = $true
        $BtnListFormats.Opacity = 1.0; $BtnListFormats.IsHitTestVisible = $true
        $BtnUpdate.Opacity = 1.0; $BtnUpdate.IsHitTestVisible = $true
        $BtnHistory.Opacity = 1.0; $BtnHistory.IsHitTestVisible = $true
        $BtnFolder.Opacity = 1.0; $BtnFolder.IsHitTestVisible = $true
        $BtnClear.Opacity = 1.0; $BtnClear.IsHitTestVisible = $true
        $BtnBrowse.Opacity = 1.0; $BtnBrowse.IsHitTestVisible = $true
        $BtnCancel.Opacity = 0.3; $BtnCancel.IsHitTestVisible = $false
    } else {
        $BtnDownload.Opacity = 0.3; $BtnDownload.IsHitTestVisible = $false
        $BtnListFormats.Opacity = 0.3; $BtnListFormats.IsHitTestVisible = $false
        $BtnUpdate.Opacity = 0.3; $BtnUpdate.IsHitTestVisible = $false
        $BtnHistory.Opacity = 0.3; $BtnHistory.IsHitTestVisible = $true
        $BtnFolder.Opacity = 0.3; $BtnFolder.IsHitTestVisible = $false
        $BtnClear.Opacity = 0.3; $BtnClear.IsHitTestVisible = $false
        $BtnBrowse.Opacity = 0.3; $BtnBrowse.IsHitTestVisible = $false
        $BtnCancel.Opacity = 1.0; $BtnCancel.IsHitTestVisible = $true
    }
}

# --- EVENT TOMBOL MUTE & OVERLAY ---
$BtnMusic.Add_Click({
    if ($global:isMuted) {
        $global:wmp.settings.mute = $false
        $global:isMuted = $false
        $BtnMusic.Content = "🔊"
        Log-Msg "🔊 Backsound dihidupkan."
    } else {
        $global:wmp.settings.mute = $true
        $global:isMuted = $true
        $BtnMusic.Content = "🔇"
        Log-Msg "🔇 Backsound dimatikan."
    }
    Save-SmartConfig # Simpan status mute langsung ke Config
})

$BtnSettings.Add_Click({
    $GridOverlay.Visibility = "Visible"
    $PanelSettings.Visibility = "Visible"
    $PanelTutorial.Visibility = "Collapsed"
})

$BtnHelp.Add_Click({
    $GridOverlay.Visibility = "Visible"
    $PanelTutorial.Visibility = "Visible"
    $PanelSettings.Visibility = "Collapsed"
})

$BtnCloseSettings.Add_Click({
    $GridOverlay.Visibility = "Collapsed"
    Save-SmartConfig
})

$BtnCloseTutorial.Add_Click({
    $GridOverlay.Visibility = "Collapsed"
})

$CboTheme.Add_SelectionChanged({
    if ($CboTheme.SelectedItem) {
        $themeVal = $CboTheme.SelectedItem.Content.ToString()
        if ($themeVal -match "Dark") { Set-AppTheme "Dark" }
        elseif ($themeVal -match "Light") { Set-AppTheme "Light" }
        else { Set-AppTheme "Auto" }
    }
})

$BtnBrowse.Add_Click({
    try {
        $app = New-Object -ComObject Shell.Application
        $folder = $app.BrowseForFolder(0, "Pilih Folder Target Unduhan:", 0, 0)
        if ($folder) {
            $TxtPath.Text = $folder.Self.Path
            Log-Msg "📂 Folder diubah ke: $($TxtPath.Text)"
            Save-SmartConfig 
        }
    } catch { Log-Msg "❌ Folder picker gagal dimuat." }
})

$BtnHistory.Add_Click({
    if (Test-Path $historyFile) { Start-Process "notepad.exe" $historyFile }
    else { Log-Msg "⚠️ Belum ada history unduhan." }
})

$RadVideo.Add_Checked({ 
    $GrpVideo.Opacity = 1.0; $GrpVideo.IsHitTestVisible = $true
    $GrpAudio.Opacity = 0.35; $GrpAudio.IsHitTestVisible = $false 
})
$RadAudio.Add_Checked({ 
    $GrpVideo.Opacity = 0.35; $GrpVideo.IsHitTestVisible = $false
    $GrpAudio.Opacity = 1.0; $GrpAudio.IsHitTestVisible = $true 
})

function Save-SmartConfig {
    if ($ChkSmartMode.IsChecked -eq $true) {
        $data = @{
            ModeVideo  = ($RadVideo.IsChecked -eq $true)
            VidResIdx  = $CboVidRes.SelectedIndex
            VidFmtIdx  = $CboVidFmt.SelectedIndex
            AudFmtIdx  = $CboAudFmt.SelectedIndex
            AudBitIdx  = $CboAudBit.SelectedIndex
            DubIdx     = $CboDubbing.SelectedIndex
            SubIdx     = $CboSubtitle.SelectedIndex
            Playlist   = ($ChkPlaylist.IsChecked -eq $true)
            UseCookies = ($ChkCookies.IsChecked -eq $true)
            BrowserIdx = $CboBrowser.SelectedIndex
            ForceMode  = ($ChkForce.IsChecked -eq $true)
            KeepVideo  = ($ChkKeepVideo.IsChecked -eq $true)
            OutPath    = $TxtPath.Text
            ThemeIdx   = $CboTheme.SelectedIndex
            IsMuted    = $global:isMuted # Simpan status mute
        }
        $data | ConvertTo-Json -Depth 2 | Out-File $configFile -Encoding UTF8 -Force
    }
}

function Load-SmartConfig {
    if (Test-Path $configFile) {
        try {
            $data = Get-Content $configFile -Raw | ConvertFrom-Json
            if ($data.ModeVideo -eq $true) { 
                $RadVideo.IsChecked = $true 
                $GrpVideo.Opacity = 1.0; $GrpVideo.IsHitTestVisible = $true
                $GrpAudio.Opacity = 0.35; $GrpAudio.IsHitTestVisible = $false
            } else { 
                $RadAudio.IsChecked = $true 
                $GrpVideo.Opacity = 0.35; $GrpVideo.IsHitTestVisible = $false
                $GrpAudio.Opacity = 1.0; $GrpAudio.IsHitTestVisible = $true
            }
            $CboVidRes.SelectedIndex  = $data.VidResIdx
            $CboVidFmt.SelectedIndex  = $data.VidFmtIdx
            $CboAudFmt.SelectedIndex  = $data.AudFmtIdx
            $CboAudBit.SelectedIndex  = $data.AudBitIdx
            if ($null -ne $data.DubIdx) { $CboDubbing.SelectedIndex = $data.DubIdx }
            if ($null -ne $data.SubIdx) { $CboSubtitle.SelectedIndex = $data.SubIdx }
            if ($null -ne $data.ThemeIdx) { $CboTheme.SelectedIndex = $data.ThemeIdx } else { $CboTheme.SelectedIndex = 2 }
            $ChkPlaylist.IsChecked    = [bool]$data.Playlist
            $ChkCookies.IsChecked     = [bool]$data.UseCookies
            $CboBrowser.SelectedIndex = $data.BrowserIdx
            $ChkForce.IsChecked       = [bool]$data.ForceMode
            $ChkKeepVideo.IsChecked   = [bool]$data.KeepVideo
            if ($data.OutPath -and (Test-Path $data.OutPath)) { $TxtPath.Text = $data.OutPath }
            
            # Load Status Mute & Rubah Ikon
            if ($null -ne $data.IsMuted) { 
                $global:isMuted = [bool]$data.IsMuted
                if ($global:isMuted) { $BtnMusic.Content = "🔇" } else { $BtnMusic.Content = "🔊" }
            }

            Log-Msg "🧠 Smart Save: Konfigurasi premium berhasil diterapkan otomatis."
        } catch {}
    } else {
        $CboTheme.SelectedIndex = 2
    }
    
    $themeVal = $CboTheme.Items[$CboTheme.SelectedIndex].Content.ToString()
    if ($themeVal -match "Dark") { Set-AppTheme "Dark" }
    elseif ($themeVal -match "Light") { Set-AppTheme "Light" }
    else { Set-AppTheme "Auto" }
}

# -----------------------------------------------------------------
# FUNGSI AUTO UPDATE SCRIPT GUI (CEK GITHUB)
# -----------------------------------------------------------------
function Check-AppUpdate {
    try {
        Log-Msg "🔄 Cek update script aplikasi (v$global:AppVersion) ke GitHub..."
        $webclient = New-Object System.Net.WebClient
        $webclient.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy([System.Net.Cache.RequestCacheLevel]::BypassCache)
        
        # Trik anti-cache: Tambahkan angka acak di akhir link agar GitHub selalu memberi file paling baru saat ini juga
        $randomUrl = $global:UpdateUrl + "?t=" + [Guid]::NewGuid().ToString()
        $remoteScript = $webclient.DownloadString($randomUrl)
        
        if ($remoteScript -match '\$global:AppVersion\s*=\s*([0-9\.]+)') {
            # Paksa baca titik sebagai desimal (Standar Internasional) agar tidak error di PC bahasa Indonesia
            $remoteVersion = [double]::Parse($Matches[1], [System.Globalization.CultureInfo]::InvariantCulture)
            $lokalVersion = [double]::Parse([string]$global:AppVersion, [System.Globalization.CultureInfo]::InvariantCulture)

            if ($remoteVersion -gt $lokalVersion) {
                Log-Msg "✨ Versi baru ditemukan: v$remoteVersion! Memulai proses update otomatis..."
                $StatStatus.Text = "⬇️ UPDATE SCRIPT"
                Refresh-Dashboard
                
                $scriptPath = $MyInvocation.MyCommand.Definition
                if (-not $scriptPath) { $scriptPath = ".\downloader.ps1" }
                
                [System.IO.File]::WriteAllText($scriptPath, $remoteScript)
                
                [System.Windows.MessageBox]::Show("Update UI versi $remoteVersion berhasil diunduh dari GitHub! Aplikasi akan ditutup untuk menerapkan pembaruan. Silakan klik file BAT kamu lagi untuk membuka versi terbaru.", "Update Selesai", "OK", "Information")
                
                $window.Close()
            } else {
                Log-Msg "✅ Script UI kamu sudah versi terbaru (v$lokalVersion)."
            }
        }
    } catch {
        Log-Msg "⚠️ Gagal mengecek update script. (Pastikan link GitHub benar dan internet aktif)"
    }
}
# -----------------------------------------------------------------

function Pengecekan-Update-Engine {
    $StatStatus.Text = "⏳ PERSIAPAN ENGINE"; $StatStatus.Foreground = "#ffb627"
    $StatSpeed.Text = "Mohon tunggu..."
    Refresh-Dashboard
    Start-Sleep -Milliseconds 500
    
    if (!(Test-Path ".\yt-dlp.exe")) { 
        Log-Msg "⏳ yt-dlp.exe tidak ditemukan! Mengunduh binary resmi..."
        Download-File-With-Progress "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" "yt-dlp.exe" "YT-DLP Core"
    } else {
        Log-Msg "🔄 Auto-Check: Mengecek versi yt-dlp terbaru..."
        $StatStatus.Text = "🔄 CEK UPDATE"; Refresh-Dashboard
        
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = ".\yt-dlp.exe"; $psi.Arguments = "-U"
        $psi.RedirectStandardOutput = $true; $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        
        while (!$p.HasExited) { Refresh-Dashboard; Start-Sleep -Milliseconds 100 }
        $outText = $p.StandardOutput.ReadToEnd().Trim()
        
        if ($outText -match 'is up to date') { Log-Msg "✅ yt-dlp sudah versi paling mutakhir!" } 
        else { Log-Msg "✅ Update yt-dlp sukses: $outText" }
    }

    if (!(Test-Path ".\ffmpeg.exe")) {
        Log-Msg "⚠️ ffmpeg.exe tidak ada di folder kerja!"
        Download-File-With-Progress "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" "ffmpeg.zip" "FFmpeg Master ZIP"
        
        Log-Msg "📦 Mengekstrak FFmpeg..."
        $StatStatus.Text = "📦 EXTRACTING..."; $StatSpeed.Text = "Sedang ekstrak..."
        Refresh-Dashboard
        Start-Sleep -Milliseconds 300 
        
        try {
            if (Test-Path ".\ffmpeg_temp") { Remove-Item ".\ffmpeg_temp" -Recurse -Force -ErrorAction SilentlyContinue }
            Expand-Archive -Path ".\ffmpeg.zip" -DestinationPath ".\ffmpeg_temp" -Force
            Move-Item -Path ".\ffmpeg_temp\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe" -Destination ".\ffmpeg.exe" -Force
            Move-Item -Path ".\ffmpeg_temp\ffmpeg-master-latest-win64-gpl\bin\ffprobe.exe" -Destination ".\ffprobe.exe" -Force
            Log-Msg "✅ FFmpeg Engine Muxer sukses terintegrasi sempurna!"
        } catch { 
            Log-Msg "❌ Gagal mengekstrak FFmpeg otomatis."
        } finally {
            Remove-Item "ffmpeg.zip" -Force -ErrorAction SilentlyContinue
            Remove-Item ".\ffmpeg_temp" -Recurse -Force -ErrorAction SilentlyContinue
        }
    } else {
        Log-Msg "✅ FFmpeg Core Muxer siap mengudara."
    }
    
    # --- AUTO-DOWNLOAD & PLAY BACKSOUND DARI YOUTUBE ---
    $backsoundFile = Join-Path (Get-Location).Path "backsound.mp3"
    if (!(Test-Path $backsoundFile)) {
        Log-Msg "🎵 Mempersiapkan audio backsound UI dari YouTube..."
        $StatStatus.Text = "⬇️ UNDUH BACKSOUND"; $StatStatus.Foreground = "#ffb627"
        Refresh-Dashboard
        
        # Ekstrak audio pakai yt-dlp
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = ".\yt-dlp.exe"
        $psi.Arguments = "-x --audio-format mp3 -o `"$backsoundFile`" `"https://youtu.be/47t_n529Jls?si=pXRYAweG7njxGGjb`""
        $psi.CreateNoWindow = $true
        $psi.UseShellExecute = $false
        
        try {
            $p = [System.Diagnostics.Process]::Start($psi)
            $p.WaitForExit()
            Log-Msg "✅ Backsound MP3 berhasil diunduh!"
        } catch {
            Log-Msg "❌ Gagal mengunduh backsound."
        }
    }
    
    if (Test-Path $backsoundFile) {
        $global:wmp.URL = $backsoundFile
        $global:wmp.settings.mute = $global:isMuted # Set dari config
        $global:wmp.controls.play()
    }

    $StatStatus.Text = "🟢 STANDBY"; $StatStatus.Foreground = $window.Resources["CyanAccent"]
    $StatSpeed.Text = "0.00 MB/s"
    Refresh-Dashboard
}

function Update-FFmpeg {
    Log-Msg "🔄 Memulai pembaruan FFmpeg ke versi Master terbaru..."
    Download-File-With-Progress "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" "ffmpeg.zip" "FFmpeg Master ZIP"
    
    Log-Msg "📦 Mengekstrak dan menimpa FFmpeg lama..."
    $StatStatus.Text = "📦 EXTRACTING..."; $StatSpeed.Text = "Sedang ekstrak..."
    Refresh-Dashboard
    Start-Sleep -Milliseconds 300 
    
    try {
        if (Test-Path ".\ffmpeg_temp") { Remove-Item ".\ffmpeg_temp" -Recurse -Force -ErrorAction SilentlyContinue }
        Expand-Archive -Path ".\ffmpeg.zip" -DestinationPath ".\ffmpeg_temp" -Force
        Move-Item -Path ".\ffmpeg_temp\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe" -Destination ".\ffmpeg.exe" -Force
        Move-Item -Path ".\ffmpeg_temp\ffmpeg-master-latest-win64-gpl\bin\ffprobe.exe" -Destination ".\ffprobe.exe" -Force
        Log-Msg "✅ FFmpeg berhasil diupdate ke rilis terbaru!"
    } catch { 
        Log-Msg "❌ Gagal mengupdate FFmpeg."
    } finally {
        Remove-Item "ffmpeg.zip" -Force -ErrorAction SilentlyContinue
        Remove-Item ".\ffmpeg_temp" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Get-Seconds ($etaStr) {
    if ($etaStr -match 'NA|Unknown' -or [string]::IsNullOrWhiteSpace($etaStr)) { return 0 }
    $parts = $etaStr.Split(':')
    try {
        if ($parts.Length -eq 3) { return ([int]$parts[0]*3600) + ([int]$parts[1]*60) + [int]$parts[2] }
        if ($parts.Length -eq 2) { return ([int]$parts[0]*60) + [int]$parts[1] }
        return [int]$etaStr
    } catch { return 0 }
}

function Download-File-With-Progress ($Url, $OutFileName, $NamaTampilan) {
    $StatStatus.Text = "⬇️ MENGUNDUH $NamaTampilan"
    $StatStatus.Foreground = "#ffb627"
    Log-Msg "⬇️ Mulai mengunduh $NamaTampilan..."
    
    $outPath = Join-Path (Get-Location).Path $OutFileName
    $webclient = New-Object System.Net.WebClient
    
    $global:dlProgress = 0
    $global:dlComplete = $false
    
    $onProgress = Register-ObjectEvent -InputObject $webclient -EventName DownloadProgressChanged -Action { $global:dlProgress = $Event.SourceEventArgs.ProgressPercentage }
    $onComplete = Register-ObjectEvent -InputObject $webclient -EventName DownloadFileCompleted -Action { $global:dlComplete = $true }
    
    $webclient.DownloadFileAsync([uri]$Url, $outPath)
    
    while (!$global:dlComplete) {
        $StatSpeed.Text = "Progress: $($global:dlProgress)%"
        Refresh-Dashboard
        Start-Sleep -Milliseconds 50
    }
    
    Unregister-Event -SourceIdentifier $onProgress.Name
    Unregister-Event -SourceIdentifier $onComplete.Name
    $webclient.Dispose()
    
    $StatSpeed.Text = "100%"
    Log-Msg "✅ Unduhan $NamaTampilan selesai (100%)!"
}

function Format-Seconds ($secs) {
    $h = [math]::Floor($secs / 3600); $m = [math]::Floor(($secs % 3600) / 60); $s = $secs % 60
    if ($h -gt 0) { return "${h}j ${m}m ${s}d" }
    return "${m}m ${s}d"
}

$window.Add_Closing({ Save-SmartConfig })

$BtnExit.Add_Click({
    Save-SmartConfig
    try {
        $global:wmp.controls.stop()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($global:wmp) | Out-Null
    } catch {}

    [Win32]::SetThreadExecutionState([Win32]::ES_CONTINUOUS)
    Get-Process -Name "yt-dlp" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "ffmpeg" -ErrorAction SilentlyContinue | Stop-Process -Force
    $window.Close()
})

$BtnCancel.Add_Click({
    if ($global:StatusMesin -eq "RUNNING") {
        $global:CancelRequested = $true
        $StatStatus.Text = "🔴 TERMINATED"
        $StatStatus.Foreground = "#ff3333"
        Log-Msg "⚠️ Kill signal dikirimkan! Mematikan yt-dlp & ffmpeg seketika..."
        Get-Process -Name "yt-dlp" -ErrorAction SilentlyContinue | Stop-Process -Force
        Get-Process -Name "ffmpeg" -ErrorAction SilentlyContinue | Stop-Process -Force
    }
})

function Jalankan-Perintah-Ytdlp ($arguments, $modeCekFormat = $false) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = ".\yt-dlp.exe"
    $psi.Arguments = $arguments
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $false
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8

    $proc = [System.Diagnostics.Process]::Start($psi)
    try { if (!$proc.HasExited) { $proc.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::High } } catch {}

    $readerOut = $proc.StandardOutput
    $taskOut = $readerOut.ReadLineAsync()

    while (!$proc.HasExited -or !$taskOut.IsCompleted) {
        if ($global:CancelRequested) { try { $proc.Kill() } catch {} break }

        if ($taskOut.IsCompleted) {
            $line = $taskOut.Result
            if ($line -ne $null) {
                if ($modeCekFormat -or ($line -notmatch '\[download\]\s+([0-9\.]+)%')) { 
                    $TxtLog.AppendText("$line`r`n"); $TxtLog.ScrollToEnd() 
                }
                if ($line -match 'Downloading\s+(?:item|video|page)\s+(\d+)\s+of\s+(\d+)') {
                    $global:PlaylistCurrentItem = [int]$Matches[1]
                    $global:PlaylistTotalItems = [int]$Matches[2]
                    $StatQueue.Text = "$($global:PlaylistCurrentItem) / $($global:PlaylistTotalItems)"
                }
                if ($line -match '\[download\]\s*(~?[0-9\.]+)%') {
                    $persen = $Matches[1] -replace '~',''
                    if ($line -match 'at\s*(~?[0-9\.]+)\s*([A-Za-z]+)/s') {
                        $speedNum = [double]($Matches[1] -replace '~',''); $speedUnit = $Matches[2]
                        if ($speedUnit -match 'K|k') { $mbConverted = $speedNum / 1024 } elseif ($speedUnit -match 'G|g') { $mbConverted = $speedNum * 1024 } elseif ($speedUnit -match 'B|b') { $mbConverted = $speedNum / 1048576 } else { $mbConverted = $speedNum }
                        $StatSpeed.Text = ("{0:N2} MB/s" -f $mbConverted) + " ($persen%)"
                    }
                    if ($line -match 'ETA\s*([0-9:a-zA-Z]+)') {
                        $currentSeconds = Get-Seconds $Matches[1]; $currentText = Format-Seconds $currentSeconds
                        if (($ChkPlaylist.IsChecked -eq $true) -and $global:PlaylistTotalItems -gt 0) {
                            $sisaLagu = $global:PlaylistTotalItems - $global:PlaylistCurrentItem + 1
                            if ($sisaLagu -lt 1) { $sisaLagu = 1 }
                            $StatETA.FontSize = 11; $StatETA.Text = "Item: $currentText`nTotal: $(Format-Seconds ($currentSeconds * $sisaLagu))"
                        } else { $StatETA.FontSize = 14; $StatETA.Text = $currentText }
                    }
                }
            }
            $taskOut = $readerOut.ReadLineAsync()
        }
        $window.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
        Start-Sleep -Milliseconds 10
    }
    return $proc.ExitCode
}

# --- URUTAN LOADING STARTUP ---
$window.Add_Loaded({
    Ubah-Status-Tombol-Aksi $false 
    Refresh-Dashboard
    
    # 1. Load Status User Dulu
    Load-SmartConfig
    
    # 2. Cek Auto-Update Script ke GitHub
    Check-AppUpdate
    
    # 3. Cek yt-dlp & Download Backsound
    Pengecekan-Update-Engine
    
    Ubah-Status-Tombol-Aksi $true 
    Log-Msg "🚀 Masterpiece UI siap tempur!"
})

$BtnFolder.Add_Click({ Start-Process explorer.exe (Get-Location).Path })

$BtnClear.Add_Click({
    $TxtLinks.Clear(); $StatQueue.Text = "0 / 0"; $StatSpeed.Text = "0.00 MB/s"
    $StatETA.Text = "0m 0d"; $StatETA.FontSize = 14; $StatStatus.Text = "🟢 STANDBY"
    $StatStatus.Foreground = $window.Resources["CyanAccent"]; $global:StatusMesin = "STANDBY"
    Log-Msg "Kotak dashboard dibersihkan."
})

$BtnClearCache.Add_Click({
    if (Test-Path ".\yt-dlp.exe") {
        Log-Msg "🧹 Sedang membersihkan cache yt-dlp..."
        $BtnClearCache.Content = "⏳ MEMBERSIHKAN CACHE..."
        Refresh-Dashboard
        try {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = ".\yt-dlp.exe"; $psi.Arguments = "--rm-cache-dir"; $psi.CreateNoWindow = $true; $psi.UseShellExecute = $false
            $p = [System.Diagnostics.Process]::Start($psi); $p.WaitForExit()
            Log-Msg "✅ Cache yt-dlp berhasil dibersihkan bersih total!"
            [System.Windows.MessageBox]::Show("Cache sistem berhasil dihapus!", "Sukses", "OK", "Information")
        } catch { Log-Msg "⚠️ Gagal membersihkan cache." }
        $BtnClearCache.Content = "🗑️ HAPUS CACHE YT-DLP"
    } else {
        [System.Windows.MessageBox]::Show("yt-dlp.exe belum ditemukan!", "Warning", "OK", "Warning")
    }
})

$BtnUpdate.Add_Click({
    Ubah-Status-Tombol-Aksi $false
    Log-Msg "🔄 Menghubungi server satelit untuk pembaruan yt-dlp Core..."
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = ".\yt-dlp.exe"; $psi.Arguments = "-U"; $psi.RedirectStandardOutput = $true; $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true
    
    $p = [System.Diagnostics.Process]::Start($psi)
    while (!$p.HasExited) { Refresh-Dashboard; Start-Sleep -Milliseconds 50 }
    
    $outText = $p.StandardOutput.ReadToEnd().Trim()
    if ($outText) { Log-Msg "ℹ️ Response yt-dlp: $outText" }
    
    # --- Tambahan Konfirmasi untuk FFmpeg ---
    $msgBox = [System.Windows.MessageBox]::Show("Update yt-dlp selesai.`n`nApakah kamu juga ingin mengunduh & mengekstrak ulang FFmpeg (Master Latest)? Ini akan memakan waktu & kuota data.", "Update FFmpeg?", "YesNo", "Question")
    
    if ($msgBox -eq "Yes") {
        Update-FFmpeg
    } else {
        Log-Msg "⏩ Update FFmpeg dibatalkan oleh pengguna (di-skip)."
    }
    
    Log-Msg "✅ Proses Pembaruan Mesin Selesai!"
    $StatStatus.Text = "🟢 STANDBY"; $StatStatus.Foreground = $window.Resources["CyanAccent"]; $StatSpeed.Text = "0.00 MB/s"
    Refresh-Dashboard; Ubah-Status-Tombol-Aksi $true
})

$BtnListFormats.Add_Click({
    if ([string]::IsNullOrWhiteSpace($TxtLinks.Text)) { [System.Windows.MessageBox]::Show("Isi link video target yang mau dicek dulu abangkuh!", "Info", "OK", "Information"); return }
    
    $links = @($TxtLinks.Text.Split(@(',', "`n", "`r"), [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Trim() })
    $targetUrl = $links[0]
    
    Ubah-Status-Tombol-Aksi $false; $global:StatusMesin = "RUNNING"; $global:CancelRequested = $false
    $StatStatus.Text = "🔍 SCAN FORMAT"; $StatStatus.Foreground = "#ffb627"
    Log-Msg "📋 Menjalankan perintah: yt-dlp --list-formats `"$targetUrl`""
    Refresh-Dashboard

    $argsList = @("--list-formats", "--no-warnings", "--no-colors")
    if ($ChkCookies.IsChecked -eq $true) { $argsList += @("--cookies-from-browser", $CboBrowser.Text.ToLower()) }
    
    $finalArgs = ($argsList -join " ") + " `"$targetUrl`""
    $exitCode = Jalankan-Perintah-Ytdlp $finalArgs -modeCekFormat $true

    $StatStatus.Text = "🟢 STANDBY"; $StatStatus.Foreground = $window.Resources["CyanAccent"]; $global:StatusMesin = "STANDBY"
    Ubah-Status-Tombol-Aksi $true
})

$BtnDownload.Add_Click({
    if ([string]::IsNullOrWhiteSpace($TxtLinks.Text)) { [System.Windows.MessageBox]::Show("Link tujuan wajib diisi abangkuh!", "Warning", "OK", "Warning"); return }
    if (!(Test-Path $TxtPath.Text)) { [System.Windows.MessageBox]::Show("Lokasi folder output penyimpanan salah!", "Warning", "OK", "Warning"); return }
    
    Save-SmartConfig; Ubah-Status-Tombol-Aksi $false; $global:StatusMesin = "RUNNING"; $global:CancelRequested = $false
    $StatStatus.Text = "🔴 PROCESSING"; $StatStatus.Foreground = "#ff3333"
    [Win32]::SetThreadExecutionState([Win32]::ES_CONTINUOUS -bor [Win32]::ES_SYSTEM_REQUIRED)

    $linkArray = @($TxtLinks.Text.Split(@(',', "`n", "`r"), [System.StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object { $_.Trim() })

    for ($i = 0; $i -lt $linkArray.Count; $i++) {
        if ($global:CancelRequested) { break }
        $url = $linkArray[$i]
        if ($url -match '^https?://' -or $url -match '^www\.' -or $url -match 'youtu\.?be') { 
            
            $global:PlaylistTotalItems = 0; $global:PlaylistCurrentItem = 0
            Log-Msg "📥 Memulai pemrosesan antrian ke-$($i + 1): $url"; $StatQueue.Text = "0 / 0"; Refresh-Dashboard

            $argsList = @()
            $folderOut = $TxtPath.Text
            $argsList += @("-o", "$folderOut\%(title)s.%(ext)s")

            if ($ChkCookies.IsChecked -eq $true) {
                $browserTarget = $CboBrowser.Text.ToLower()
                $argsList += @("--cookies-from-browser", $browserTarget)
            }

            if ($RadVideo.IsChecked -eq $true) {
                $resTarget = $arrVidRes[$CboVidRes.SelectedIndex]
                $fmtTarget = $arrVidFmt[$CboVidFmt.SelectedIndex]
                
                $dubIdx = $CboDubbing.SelectedIndex
                $audioTrack = "bestaudio"
                
                if ($dubIdx -eq 1) { 
                    $audioTrack = "allaudio" 
                    $argsList += "--audio-multistreams"
                }
                elseif ($dubIdx -eq 2) { $audioTrack = "bestaudio[language=id]" }
                elseif ($dubIdx -eq 3) { $audioTrack = "bestaudio[language=en]" }
                elseif ($dubIdx -eq 4) { $audioTrack = "bestaudio[language=zh]" }

                if ($fmtTarget -eq "mp4") {
                    $argsList += @("-f", "bestvideo[height<=$resTarget][ext=mp4]+$audioTrack[ext=m4a]/bestvideo[height<=$resTarget]+bestaudio/best")
                } else {
                    $argsList += @("-f", "bestvideo[height<=$resTarget]+$audioTrack/bestvideo[height<=$resTarget]+bestaudio/best")
                }
                
                $argsList += @("--remux-video", $fmtTarget)
            } else {
                $fmtTarget = $arrAudFmt[$CboAudFmt.SelectedIndex]
                $argsList += @("-x", "--audio-format", $fmtTarget)
                
                if ($fmtTarget -match "mp3|m4a|ogg") { 
                    $bitTarget = $arrAudBit[$CboAudBit.SelectedIndex]
                    $argsList += @("--audio-quality", $bitTarget) 
                }
                
                if ($ChkKeepVideo.IsChecked -eq $true) {
                    $argsList += "-k"; Log-Msg "💾 Flag [-k] Aktif: File video asli akan tetap dipertahankan."
                }
            }
            
            $argsList += @("--embed-thumbnail", "--embed-metadata", "--prefer-ffmpeg")

            if ($RadVideo.IsChecked -eq $true) { 
                $subIdx = $CboSubtitle.SelectedIndex
                if ($subIdx -eq 0) { 
                    $argsList += @("--write-sub", "--write-auto-subs", "--sub-langs", "all", "--embed-subs", "--convert-subs", "srt") 
                } elseif ($subIdx -eq 1) { 
                    $argsList += @("--write-sub", "--write-auto-subs", "--sub-langs", "id", "--embed-subs", "--convert-subs", "srt") 
                } elseif ($subIdx -eq 2) { 
                    $argsList += @("--write-sub", "--write-auto-subs", "--sub-langs", "en", "--embed-subs", "--convert-subs", "srt") 
                }
            }

            $argsList += @("--newline", "--ignore-errors", "--no-warnings", "--no-colors", "--ffmpeg-location", ".\ffmpeg.exe")
            $argsList += @("--fragment-retries", "30", "--file-access-retries", "30", "--retries", "30", "--socket-timeout", "30")
            $argsList += @("--downloader-args", "ffmpeg_i:-reconnect 1 -reconnect_streamed 1")
            $argsList += @("--extractor-args", "youtube:player_client=android,tv,web")

            if ($ChkPlaylist.IsChecked -eq $true) { $argsList += "--yes-playlist" } else { $argsList += "--no-playlist" }
            if ($ChkForce.IsChecked -eq $true) { $argsList += @("-N", "5", "--concurrent-fragments", "5") }

            $sanitizedArgs = @()
            foreach ($arg in $argsList) { 
                if ($arg -match '\s|%') { $sanitizedArgs += "`"$arg`"" } else { $sanitizedArgs += $arg } 
            }
            $finalArgsString = ($sanitizedArgs -join " ") + " `"$url`""

            $exitCode = Jalankan-Perintah-Ytdlp $finalArgsString
            
            if (-not $global:CancelRequested) {
                $histData = "[$([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss'))] Sukses: $url -> Folder: $folderOut"
                Add-Content -Path $historyFile -Value $histData
            }

            if ($global:CancelRequested) { break }
            $StatSpeed.Text = "0.00 MB/s"; $StatETA.Text = "0m 0d"; Refresh-Dashboard
        }
    }

    if ($global:CancelRequested) {
        $StatStatus.Text = "🟢 STANDBY"; $StatStatus.Foreground = $window.Resources["CyanAccent"]; Log-Msg "🛑 Sesi download dibatalkan dengan aman."
    } else {
        Log-Msg "🚀 KELAR TOTAL! Seluruh antrian perintah yt-dlp & ffmpeg sukses dikerjakan."
        $StatStatus.Text = "✅ SELESAI"; $StatStatus.Foreground = "#00ff00"
        if ($ChkShutdown.IsChecked -eq $true) { & shutdown.exe /s /t 60 /c "Cinnamon Downloader Masterpiece: Shutdown Otomatis." }
    }
    
    [Win32]::SetThreadExecutionState([Win32]::ES_CONTINUOUS)
    Ubah-Status-Tombol-Aksi $true
})

$window.ShowDialog() | Out-Null