import subprocess
import logging
from datetime import datetime

logging.basicConfig(filename='logs/patch_log.txt', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def _run_powershell(cmd):
    full_cmd = f'powershell -NoProfile -NonInteractive -Command "{cmd}"'
    logging.info("Running PowerShell: %s", cmd)
    try:
        completed = subprocess.run(full_cmd, shell=True,
                                   capture_output=True, text=True, timeout=1800)
        logging.info("Return code: %s", completed.returncode)
        if completed.stdout:
            logging.info("Stdout: %s", completed.stdout.strip())
        if completed.stderr:
            logging.info("Stderr: %s", completed.stderr.strip())
        return completed.returncode, completed.stdout, completed.stderr
    except subprocess.TimeoutExpired as e:
        logging.error("PowerShell command timed out: %s", e)
        return -1, "", str(e)
    except Exception as e:
        logging.exception("Error running PowerShell command")
        return -1, "", str(e)

def ensure_pswindowsupdate_installed():
    check_cmd = "if (Get-Module -ListAvailable -Name PSWindowsUpdate) { Write-Output 'Installed' } else { Write-Output 'NotInstalled' }"
    rc, out, err = _run_powershell(check_cmd)
    
    if rc != 0:
        return False, f"Error checking PSWindowsUpdate: {err or out}"
    
    if "Installed" in out:
        return True, "PSWindowsUpdate already installed."
        
    install_cmd = (
        "Try { Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -Confirm:$false -ErrorAction Stop; "
        "Write-Output 'InstalledOK' } Catch { Write-Output 'InstallFailed'; Write-Output $_.Exception.Message }"
    )
    rc2, out2, err2 = _run_powershell(install_cmd)
    
    if rc2 == 0 and "InstalledOK" in out2:
        return True, "PSWindowsUpdate installed successfully."
    else:
        msg = out2.strip() or err2.strip() or "Unknown error during install"
        return False, f"PSWindowsUpdate install failed: {msg}"

def check_installed_software():
    cmd = "Get-WmiObject -Class Win32_Product | Select-Object Name, Version | Format-Table -AutoSize"
    rc, out, err = _run_powershell(cmd)
    if rc == 0:
        return out.strip() or "No output (no products found or access restricted)."
    else:
        return f"Error checking installed software: {err or out}"

def list_installed_hotfixes():
    cmd = "wmic qfe list brief /format:table"
    rc, out, err = _run_powershell(cmd)
    if rc == 0:
        return out.strip() or "No hotfixes listed."
    else:
        return f"Error listing hotfixes: {err or out}"

def check_available_updates():
    rc_installed, msg = ensure_pswindowsupdate_installed()
    if not rc_installed:
        return f"PSWindowsUpdate not available: {msg}"
    
    cmd = "Import-Module PSWindowsUpdate; Get-WindowsUpdate -AcceptAll -IgnoreReboot -Verbose -ErrorAction Stop | Select-Object Title, KB, Size, MsrcSeverity | Format-Table -AutoSize"
    rc, out, err = _run_powershell(cmd)
    if rc == 0:
        return out.strip() or "No updates available."
    else:
        return f"Error checking updates: {err or out}"

def download_updates():
    rc_installed, msg = ensure_pswindowsupdate_installed()
    if not rc_installed:
        return False, f"PSWindowsUpdate not available: {msg}"
    
    cmd = "Import-Module PSWindowsUpdate; Get-WindowsUpdate -AcceptAll -Download -IgnoreReboot -ErrorAction Stop | Out-String -Width 200"
    rc, out, err = _run_powershell(cmd)
    
    if rc == 0:
        return True, out.strip() or "Downloaded updates (if any)."
    else:
        return False, f"Error downloading updates: {err or out}"

def install_updates(ignore_reboot=True):
    rc_installed, msg = ensure_pswindowsupdate_installed()
    if not rc_installed:
        return False, f"PSWindowsUpdate not available: {msg}"
        
    ignore_reboot_flag = "-IgnoreReboot" if ignore_reboot else ""
    cmd = f"Import-Module PSWindowsUpdate; Install-WindowsUpdate -AcceptAll {ignore_reboot_flag} -Verbose -ErrorAction Stop | Out-String -Width 200"
    rc, out, err = _run_powershell(cmd)
    
    if rc == 0:
        return True, out.strip() or "Installed updates successfully (some updates may still require manual reboot)."
    else:
        return False, f"Error installing updates: {err or out}"

def health_status():
    try:
        rc_installed, msg = ensure_pswindowsupdate_installed()
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        return {
            "pswindowsupdate": msg,
            "timestamp": now
        }
    except Exception as e:
        return {"error": str(e)}

def check_third_party_updates():
    cmd = "winget list --upgrade-available --accept-source-agreements"
    rc, out, err = _run_powershell(cmd)
    if rc == 0:
        return out.strip() or "No third-party updates available or winget not found."
    else:
        return f"Error checking third-party updates: {err or out}"

def install_third_party_updates():
    cmd = "winget upgrade --all --silent --accept-source-agreements --accept-package-agreements"
    rc, out, err = _run_powershell(cmd)
    if rc == 0:
        return True, out.strip() or "Installed third-party updates successfully."
    else:
        return False, f"Error installing third-party updates: {err or out}"