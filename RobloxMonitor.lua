"""
NETWORK OPTIMIZER & MONITOR TOOL
Professional Network Management Tool for Daily Use

Features:
- Real-time network monitoring (ping, speed, latency)
- One-click network optimization
- DNS optimizer (auto find fastest DNS)
- Connection diagnostics
- Network history & statistics
- Auto-optimize on startup (optional)
- System tray integration
- Administrator mode for advanced operations

Author: AI Assistant
Version: 1.1
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import threading
import subprocess
import platform
import time
import socket
import json
import os
import sys
import ctypes
from datetime import datetime
import requests

class NetworkOptimizerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Network Optimizer & Monitor - Professional Tool")
        self.root.geometry("950x750")
        self.root.resizable(False, False)
        
        # Variables
        self.is_monitoring = False
        self.monitor_thread = None
        self.ping_history = []
        self.os_type = platform.system()
        self.is_admin = self.check_admin()
        
        # Colors
        self.colors = {
            'bg': '#1a1a2e',
            'secondary': '#16213e',
            'accent': '#0f3460',
            'success': '#00ff88',
            'warning': '#ffa500',
            'danger': '#ff4444',
            'admin': '#8a2be2',  # Purple for admin mode
            'text': '#ffffff'
        }
        
        # Configure root
        self.root.configure(bg=self.colors['bg'])
        
        # Create GUI
        self.create_gui()
        
        # Load settings
        self.load_settings()
        
    def check_admin(self):
        """Check if running as administrator/root"""
        try:
            if self.os_type == "Windows":
                return ctypes.windll.shell32.IsUserAnAdmin() != 0
            else:
                return os.getuid() == 0  # Unix/Linux
        except:
            return False
    
    def create_gui(self):
        """Create main GUI layout"""
        
        # ========== HEADER ==========
        header_frame = tk.Frame(self.root, bg=self.colors['secondary'], height=90)
        header_frame.pack(fill='x', padx=10, pady=10)
        header_frame.pack_propagate(False)
        
        # Title with admin indicator
        title_text = "🌐 NETWORK OPTIMIZER & MONITOR"
        if self.is_admin:
            title_text += " [ADMIN MODE] ⚡"
        
        title_label = tk.Label(
            header_frame,
            text=title_text,
            font=('Arial', 20, 'bold'),
            bg=self.colors['secondary'],
            fg=self.colors['success'] if not self.is_admin else self.colors['admin']
        )
        title_label.pack(pady=5)
        
        subtitle_label = tk.Label(
            header_frame,
            text="Professional Network Management Tool for Daily Use",
            font=('Arial', 10),
            bg=self.colors['secondary'],
            fg=self.colors['text']
        )
        subtitle_label.pack()
        
        # Admin status label
        admin_status = "✅ Running as Administrator" if self.is_admin else "⚠️ Limited Mode - Some features require Admin"
        admin_label = tk.Label(
            header_frame,
            text=admin_status,
            font=('Arial', 9, 'italic'),
            bg=self.colors['secondary'],
            fg=self.colors['admin'] if self.is_admin else self.colors['warning']
        )
        admin_label.pack(pady=2)
        
        # ========== STATS FRAME ==========
        stats_frame = tk.Frame(self.root, bg=self.colors['bg'])
        stats_frame.pack(fill='x', padx=10, pady=5)
        
        # Ping Display
        self.ping_frame = self.create_stat_card(stats_frame, "📡 PING", "-- ms", 0)
        # Speed Display
        self.speed_frame = self.create_stat_card(stats_frame, "⚡ SPEED", "-- Mbps", 1)
        # Status Display
        self.status_frame = self.create_stat_card(stats_frame, "🔌 STATUS", "Idle", 2)
        # Admin Status
        self.admin_frame = self.create_stat_card(stats_frame, "👑 ADMIN", "No" if not self.is_admin else "Yes", 3)
        
        # ========== CONTROL BUTTONS ==========
        control_frame = tk.Frame(self.root, bg=self.colors['bg'])
        control_frame.pack(fill='x', padx=10, pady=10)
        
        # Row 1
        self.monitor_btn = tk.Button(
            control_frame,
            text="▶ START MONITORING",
            font=('Arial', 11, 'bold'),
            bg=self.colors['success'],
            fg=self.colors['bg'],
            command=self.toggle_monitoring,
            relief='flat',
            cursor='hand2',
            height=2,
            width=22
        )
        self.monitor_btn.grid(row=0, column=0, padx=3, pady=3)
        
        optimize_btn = tk.Button(
            control_frame,
            text="🚀 OPTIMIZE NETWORK",
            font=('Arial', 11, 'bold'),
            bg=self.colors['accent'],
            fg=self.colors['text'],
            command=self.optimize_network,
            relief='flat',
            cursor='hand2',
            height=2,
            width=22
        )
        optimize_btn.grid(row=0, column=1, padx=3, pady=3)
        
        dns_btn = tk.Button(
            control_frame,
            text="🔧 OPTIMIZE DNS",
            font=('Arial', 11, 'bold'),
            bg=self.colors['warning'],
            fg=self.colors['bg'],
            command=self.optimize_dns,
            relief='flat',
            cursor='hand2',
            height=2,
            width=22
        )
        dns_btn.grid(row=0, column=2, padx=3, pady=3)
        
        # Row 2
        diagnose_btn = tk.Button(
            control_frame,
            text="🔍 DIAGNOSE",
            font=('Arial', 11, 'bold'),
            bg=self.colors['danger'],
            fg=self.colors['text'],
            command=self.diagnose_connection,
            relief='flat',
            cursor='hand2',
            height=2,
            width=22
        )
        diagnose_btn.grid(row=1, column=0, padx=3, pady=3)
        
        admin_btn = tk.Button(
            control_frame,
            text="👑 ADMIN TOOLS",
            font=('Arial', 11, 'bold'),
            bg=self.colors['admin'],
            fg=self.colors['text'],
            command=self.open_admin_tools,
            relief='flat',
            cursor='hand2',
            height=2,
            width=22
        )
        admin_btn.grid(row=1, column=1, padx=3, pady=3)
        
        # Restart as Admin button (only if not already admin)
        if not self.is_admin:
            restart_admin_btn = tk.Button(
                control_frame,
                text="⚡ RESTART AS ADMIN",
                font=('Arial', 11, 'bold'),
                bg='#ff4444',
                fg=self.colors['text'],
                command=self.restart_as_admin,
                relief='flat',
                cursor='hand2',
                height=2,
                width=22
            )
            restart_admin_btn.grid(row=1, column=2, padx=3, pady=3)
        
        # ========== ADVANCED FRAME (Collapsible) ==========
        self.advanced_frame = tk.Frame(self.root, bg=self.colors['secondary'])
        self.advanced_frame.pack(fill='x', padx=10, pady=5)
        self.advanced_frame.pack_forget()  # Hidden by default
        
        advanced_label = tk.Label(
            self.advanced_frame,
            text="🔧 ADVANCED ADMIN COMMANDS",
            font=('Arial', 11, 'bold'),
            bg=self.colors['secondary'],
            fg=self.colors['admin']
        )
        advanced_label.grid(row=0, column=0, columnspan=3, pady=5)
        
        # Advanced buttons
        adv_buttons = [
            ("🔄 Reset Firewall", self.reset_firewall),
            ("📶 WiFi Diagnostics", self.wifi_diagnostics),
            ("🔒 Block Ping", self.toggle_ping_block),
            ("🧹 Clean Hosts", self.clean_hosts_file),
            ("🔗 Route Table", self.show_routing_table),
            ("📊 TCP Optimize", self.optimize_tcp)
        ]
        
        for i, (text, command) in enumerate(adv_buttons):
            btn = tk.Button(
                self.advanced_frame,
                text=text,
                font=('Arial', 9),
                bg=self.colors['accent'],
                fg=self.colors['text'],
                command=command,
                relief='flat',
                cursor='hand2',
                width=15,
                height=1
            )
            btn.grid(row=1 + i//3, column=i%3, padx=5, pady=3)
        
        # ========== LOG/OUTPUT AREA ==========
        log_frame = tk.Frame(self.root, bg=self.colors['bg'])
        log_frame.pack(fill='both', expand=True, padx=10, pady=5)
        
        log_header = tk.Frame(log_frame, bg=self.colors['bg'])
        log_header.pack(fill='x')
        
        log_label = tk.Label(
            log_header,
            text="📋 Activity Log",
            font=('Arial', 12, 'bold'),
            bg=self.colors['bg'],
            fg=self.colors['text']
        )
        log_label.pack(side='left', pady=5)
        
        # Clear log button
        clear_btn = tk.Button(
            log_header,
            text="🗑️ Clear Log",
            font=('Arial', 8),
            bg=self.colors['danger'],
            fg=self.colors['text'],
            command=self.clear_log,
            relief='flat',
            cursor='hand2',
            width=10
        )
        clear_btn.pack(side='right', padx=5)
        
        # Save log button
        save_btn = tk.Button(
            log_header,
            text="💾 Save Log",
            font=('Arial', 8),
            bg=self.colors['accent'],
            fg=self.colors['text'],
            command=self.save_log,
            relief='flat',
            cursor='hand2',
            width=10
        )
        save_btn.pack(side='right', padx=5)
        
        self.log_text = scrolledtext.ScrolledText(
            log_frame,
            height=15,
            font=('Consolas', 10),
            bg=self.colors['secondary'],
            fg=self.colors['success'],
            insertbackground=self.colors['success'],
            relief='flat',
            wrap='word'
        )
        self.log_text.pack(fill='both', expand=True)
        
        # ========== FOOTER ==========
        footer_frame = tk.Frame(self.root, bg=self.colors['secondary'], height=40)
        footer_frame.pack(fill='x', side='bottom')
        footer_frame.pack_propagate(False)
        
        footer_label = tk.Label(
            footer_frame,
            text=f"System: {self.os_type} | Admin: {'Yes' if self.is_admin else 'No'} | Version: 1.1",
            font=('Arial', 9),
            bg=self.colors['secondary'],
            fg=self.colors['text']
        )
        footer_label.pack(pady=10)
        
        # Initial log
        self.log("✅ Network Optimizer Tool Started")
        self.log(f"🖥️ Operating System: {self.os_type}")
        if self.is_admin:
            self.log("⚡ Running with Administrator privileges")
            self.log("👑 Advanced features are available")
        else:
            self.log("⚠️ Running in limited mode - Some features require Admin rights")
            self.log("💡 Tip: Click 'RESTART AS ADMIN' for full features")
        self.log("💡 Click 'START MONITORING' to begin tracking your network")
        
    def create_stat_card(self, parent, title, value, column):
        """Create a stat display card"""
        card_frame = tk.Frame(parent, bg=self.colors['secondary'], relief='flat')
        card_frame.grid(row=0, column=column, padx=5, sticky='ew')
        parent.grid_columnconfigure(column, weight=1)
        
        title_label = tk.Label(
            card_frame,
            text=title,
            font=('Arial', 10, 'bold'),
            bg=self.colors['secondary'],
            fg=self.colors['text']
        )
        title_label.pack(pady=(10, 5))
        
        value_label = tk.Label(
            card_frame,
            text=value,
            font=('Arial', 20, 'bold'),
            bg=self.colors['secondary'],
            fg=self.colors['success']
        )
        value_label.pack(pady=(0, 10))
        
        # Store value label for updates
        if column == 0:
            self.ping_label = value_label
        elif column == 1:
            self.speed_label = value_label
        elif column == 2:
            self.status_label = value_label
        elif column == 3:
            self.admin_label = value_label
            value_label.config(fg=self.colors['admin'] if value == "Yes" else self.colors['warning'])
            
        return card_frame
    
    def log(self, message, color=None):
        """Add message to log"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        log_message = f"[{timestamp}] {message}\n"
        
        self.log_text.insert('end', log_message)
        self.log_text.see('end')
        
        # Auto color coding
        if "❌" in message or "ERROR" in message.upper() or "FAILED" in message.upper():
            self.log_text.tag_add("error", "end-2c linestart", "end-1c")
        elif "✅" in message or "SUCCESS" in message.upper() or "PASSED" in message.upper():
            self.log_text.tag_add("success", "end-2c linestart", "end-1c")
        elif "⚠️" in message or "WARNING" in message.upper():
            self.log_text.tag_add("warning", "end-2c linestart", "end-1c")
        
        self.root.update_idletasks()
    
    def clear_log(self):
        """Clear the log window"""
        self.log_text.delete(1.0, tk.END)
        self.log("Log cleared")
    
    def save_log(self):
        """Save log to file"""
        try:
            log_content = self.log_text.get(1.0, tk.END)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"network_optimizer_log_{timestamp}.txt"
            
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(log_content)
            
            self.log(f"✅ Log saved to: {filename}")
            messagebox.showinfo("Success", f"Log saved to:\n{os.path.abspath(filename)}")
        except Exception as e:
            self.log(f"❌ Failed to save log: {str(e)}")
            messagebox.showerror("Error", f"Failed to save log:\n{str(e)}")
    
    def toggle_monitoring(self):
        """Start/Stop network monitoring"""
        if not self.is_monitoring:
            self.is_monitoring = True
            self.monitor_btn.config(
                text="⏸ STOP MONITORING",
                bg=self.colors['danger']
            )
            self.status_label.config(text="Monitoring", fg=self.colors['success'])
            
            self.log("🚀 Started network monitoring...")
            self.monitor_thread = threading.Thread(target=self.monitor_loop, daemon=True)
            self.monitor_thread.start()
        else:
            self.is_monitoring = False
            self.monitor_btn.config(
                text="▶ START MONITORING",
                bg=self.colors['success']
            )
            self.status_label.config(text="Stopped", fg=self.colors['warning'])
            self.log("⏸ Stopped network monitoring")
    
    def open_admin_tools(self):
        """Open advanced admin tools panel"""
        if self.advanced_frame.winfo_ismapped():
            self.advanced_frame.pack_forget()
            self.log("🔽 Admin tools panel hidden")
        else:
            self.advanced_frame.pack(fill='x', padx=10, pady=5)
            self.log("🔼 Admin tools panel opened")
            
            if not self.is_admin:
                self.log("⚠️ Note: Some admin features require Administrator privileges")
    
    def restart_as_admin(self):
        """Restart the application as administrator"""
        if messagebox.askyesno("Restart as Administrator", 
                              "This will restart the application with Administrator privileges.\n\n"
                              "Do you want to continue?"):
            try:
                if self.os_type == "Windows":
                    # Relaunch as admin on Windows
                    ctypes.windll.shell32.ShellExecuteW(
                        None, "runas", sys.executable, " ".join(sys.argv), None, 1
                    )
                elif self.os_type == "Linux" or self.os_type == "Darwin":
                    # For Linux/macOS, suggest using sudo
                    self.log("⚠️ On Linux/macOS, run with: sudo python network_optimizer.py")
                    messagebox.showinfo("Linux/macOS", 
                                       "To run as administrator on Linux/macOS:\n\n"
                                       "1. Close this application\n"
                                       "2. Open terminal\n"
                                       "3. Run: sudo python network_optimizer.py")
                    return
                
                # Close current instance
                self.root.destroy()
                
            except Exception as e:
                self.log(f"❌ Failed to restart as admin: {str(e)}")
                messagebox.showerror("Error", "Failed to restart as administrator")
    
    def reset_firewall(self):
        """Reset firewall to default settings"""
        if not self.is_admin:
            self.log("❌ This feature requires Administrator privileges")
            messagebox.showwarning("Admin Required", "This feature requires Administrator privileges.")
            return
            
        if messagebox.askyesno("Reset Firewall", 
                              "⚠️ WARNING: This will reset firewall to default settings!\n\n"
                              "All custom rules will be lost.\n"
                              "Are you sure you want to continue?"):
            self.log("🔄 Resetting firewall to default settings...")
            
            try:
                if self.os_type == "Windows":
                    # Reset Windows Firewall
                    subprocess.run(["netsh", "advfirewall", "reset"], 
                                 capture_output=True, text=True, check=True)
                    self.log("✅ Windows Firewall reset successfully")
                    messagebox.showinfo("Success", "Firewall has been reset to default settings.")
                else:
                    self.log("⚠️ Firewall reset not implemented for this OS")
                    messagebox.showinfo("Info", "Manual firewall reset required for this OS.")
            except Exception as e:
                self.log(f"❌ Failed to reset firewall: {str(e)}")
                messagebox.showerror("Error", f"Failed to reset firewall:\n{str(e)}")
    
    def wifi_diagnostics(self):
        """Run WiFi diagnostics"""
        self.log("📶 Running WiFi diagnostics...")
        
        def run_diagnostics():
            try:
                if self.os_type == "Windows":
                    # Run Windows WiFi diagnostic
                    result = subprocess.run(
                        ["netsh", "wlan", "show", "interfaces"],
                        capture_output=True, text=True, check=True
                    )
                    self.log("📊 WiFi Interfaces:")
                    for line in result.stdout.split('\n'):
                        if line.strip():
                            self.log(f"  {line.strip()}")
                    
                    # Show connected networks
                    result = subprocess.run(
                        ["netsh", "wlan", "show", "networks", "mode=bssid"],
                        capture_output=True, text=True
                    )
                    self.log("\n📡 Available Networks:")
                    networks = result.stdout.split('SSID')
                    for network in networks[1:6]:  # Show first 5 networks
                        lines = network.split('\n')
                        if lines:
                            ssid = lines[0].strip().strip(':')
                            if ssid:
                                self.log(f"  📶 {ssid}")
                
                elif self.os_type == "Linux":
                    # Linux WiFi diagnostics
                    subprocess.run(["iwconfig"], capture_output=True, text=True)
                    self.log("✅ Linux WiFi diagnostics complete")
                
                else:
                    self.log("ℹ️ WiFi diagnostics available for Windows and Linux only")
                
            except Exception as e:
                self.log(f"❌ WiFi diagnostics failed: {str(e)}")
        
        threading.Thread(target=run_diagnostics, daemon=True).start()
    
    def toggle_ping_block(self):
        """Enable/Disable ping responses"""
        if not self.is_admin:
            self.log("❌ This feature requires Administrator privileges")
            messagebox.showwarning("Admin Required", "This feature requires Administrator privileges.")
            return
            
        self.log("🔒 Toggping ICMP (ping) response settings...")
        
        try:
            if self.os_type == "Windows":
                # Get current state
                result = subprocess.run(
                    ["netsh", "advfirewall", "firewall", "show", "rule", "name=all"],
                    capture_output=True, text=True
                )
                
                if "File and Printer Sharing (Echo Request - ICMPv4-In)" in result.stdout:
                    # Disable ping
                    subprocess.run([
                        "netsh", "advfirewall", "firewall", "set", "rule",
                        "name=\"File and Printer Sharing (Echo Request - ICMPv4-In)\"", "new", "enable=no"
                    ], check=True)
                    self.log("✅ Ping responses DISABLED")
                    messagebox.showinfo("Success", "Ping responses have been disabled")
                else:
                    # Enable ping
                    subprocess.run([
                        "netsh", "advfirewall", "firewall", "add", "rule",
                        "name=\"Allow ICMPv4-In\"", "dir=in", "action=allow",
                        "protocol=icmpv4:8,any"
                    ], check=True)
                    self.log("✅ Ping responses ENABLED")
                    messagebox.showinfo("Success", "Ping responses have been enabled")
            
            else:
                self.log("⚠️ Ping block toggle not implemented for this OS")
                messagebox.showinfo("Info", "Manual configuration required for this OS.")
                
        except Exception as e:
            self.log(f"❌ Failed to toggle ping block: {str(e)}")
            messagebox.showerror("Error", f"Failed to toggle ping block:\n{str(e)}")
    
    def clean_hosts_file(self):
        """Clean the hosts file from unwanted entries"""
        if not self.is_admin:
            self.log("❌ This feature requires Administrator privileges")
            messagebox.showwarning("Admin Required", "This feature requires Administrator privileges.")
            return
            
        if messagebox.askyesno("Clean Hosts File", 
                              "⚠️ This will clean your hosts file.\n\n"
                              "It will remove potentially malicious entries.\n"
                              "Backup will be created automatically.\n"
                              "Continue?"):
            self.log("🧹 Cleaning hosts file...")
            
            try:
                hosts_path = ""
                if self.os_type == "Windows":
                    hosts_path = r"C:\Windows\System32\drivers\etc\hosts"
                elif self.os_type == "Linux":
                    hosts_path = "/etc/hosts"
                elif self.os_type == "Darwin":
                    hosts_path = "/etc/hosts"
                
                # Create backup
                backup_path = hosts_path + ".backup"
                with open(hosts_path, 'r') as f:
                    content = f.read()
                
                with open(backup_path, 'w') as f:
                    f.write(content)
                
                # Filter out suspicious entries
                lines = content.split('\n')
                clean_lines = []
                suspicious_count = 0
                
                for line in lines:
                    line_stripped = line.strip()
                    # Keep comments, localhost entries, and empty lines
                    if (line_stripped.startswith('#') or 
                        line_stripped == '' or
                        'localhost' in line_stripped.lower() or
                        '127.0.0.1' in line_stripped or
                        '::1' in line_stripped):
                        clean_lines.append(line)
                    else:
                        # Check for potentially malicious entries
                        if any(site in line_stripped.lower() for site in ['facebook', 'youtube', 'google', 'ad', 'track']):
                            suspicious_count += 1
                            clean_lines.append(f"# REMOVED: {line}")
                        else:
                            clean_lines.append(line)
                
                # Write cleaned content
                with open(hosts_path, 'w') as f:
                    f.write('\n'.join(clean_lines))
                
                self.log(f"✅ Hosts file cleaned. Removed {suspicious_count} suspicious entries.")
                self.log(f"📁 Backup saved to: {backup_path}")
                messagebox.showinfo("Success", 
                                  f"Hosts file cleaned successfully!\n\n"
                                  f"Suspicious entries removed: {suspicious_count}\n"
                                  f"Backup: {backup_path}")
                
            except Exception as e:
                self.log(f"❌ Failed to clean hosts file: {str(e)}")
                messagebox.showerror("Error", f"Failed to clean hosts file:\n{str(e)}")
    
    def show_routing_table(self):
        """Display routing table"""
        self.log("🔗 Displaying routing table...")
        
        try:
            if self.os_type == "Windows":
                result = subprocess.run(["route", "print"], capture_output=True, text=True)
            else:
                result = subprocess.run(["netstat", "-rn"], capture_output=True, text=True)
            
            self.log("📊 Routing Table:")
            for line in result.stdout.split('\n')[:20]:  # Show first 20 lines
                if line.strip():
                    self.log(f"  {line}")
            
            self.log("... (truncated)")
            
        except Exception as e:
            self.log(f"❌ Failed to show routing table: {str(e)}")
    
    def optimize_tcp(self):
        """Optimize TCP/IP settings for better performance"""
        if not self.is_admin:
            self.log("❌ This feature requires Administrator privileges")
            messagebox.showwarning("Admin Required", "This feature requires Administrator privileges.")
            return
            
        self.log("📊 Optimizing TCP/IP settings...")
        
        try:
            if self.os_type == "Windows":
                # Disable TCP auto-tuning (can cause issues)
                subprocess.run(["netsh", "int", "tcp", "set", "global", "autotuninglevel=disabled"], 
                             capture_output=True, check=True)
                
                # Enable TCP chimney offload
                subprocess.run(["netsh", "int", "tcp", "set", "global", "chimney=enabled"], 
                             capture_output=True, check=True)
                
                # Increase TCP window size
                subprocess.run(["netsh", "int", "tcp", "set", "global", "initialRto=1000"], 
                             capture_output=True, check=True)
                
                self.log("✅ TCP/IP settings optimized")
                messagebox.showinfo("Success", "TCP/IP settings have been optimized for better performance.")
                
            else:
                self.log("⚠️ TCP optimization not implemented for this OS")
                messagebox.showinfo("Info", "Manual TCP optimization required for this OS.")
                
        except Exception as e:
            self.log(f"❌ TCP optimization failed: {str(e)}")
            messagebox.showerror("Error", f"TCP optimization failed:\n{str(e)}")
    
    # ========== EXISTING METHODS (keep from original) ==========
    
    def monitor_loop(self):
        """Main monitoring loop"""
        while self.is_monitoring:
            try:
                # Ping test
                ping_result = self.ping_test("8.8.8.8")
                
                if ping_result:
                    self.ping_label.config(text=f"{ping_result} ms")
                    self.ping_history.append(ping_result)
                    
                    # Keep only last 100 entries
                    if len(self.ping_history) > 100:
                        self.ping_history.pop(0)
                    
                    # Calculate average
                    avg_ping = sum(self.ping_history) / len(self.ping_history)
                    
                    # Color based on ping
                    if avg_ping < 50:
                        color = self.colors['success']
                    elif avg_ping < 100:
                        color = self.colors['warning']
                    else:
                        color = self.colors['danger']
                    
                    self.ping_label.config(fg=color)
                else:
                    self.ping_label.config(text="N/A", fg=self.colors['danger'])
                
                time.sleep(2)  # Update every 2 seconds
                
            except Exception as e:
                self.log(f"❌ Monitoring error: {str(e)}")
                time.sleep(5)
    
    def ping_test(self, host):
        """Test ping to host"""
        try:
            if self.os_type == "Windows":
                command = ["ping", "-n", "1", host]
            else:
                command = ["ping", "-c", "1", host]
            
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=3
            )
            
            output = result.stdout
            
            # Parse ping time
            if self.os_type == "Windows":
                if "time=" in output or "time<" in output:
                    # Extract time value
                    for line in output.split('\n'):
                        if 'time' in line.lower():
                            if 'time=' in line:
                                time_str = line.split('time=')[1].split('ms')[0].strip()
                            elif 'time<' in line:
                                time_str = line.split('time<')[1].split('ms')[0].strip()
                            try:
                                return int(float(time_str))
                            except:
                                pass
            else:
                if "time=" in output:
                    time_str = output.split('time=')[1].split(' ')[0]
                    return int(float(time_str))
            
            return None
            
        except Exception as e:
            return None
    
    def optimize_network(self):
        """Optimize network settings"""
        self.log("🚀 Starting network optimization...")
        self.status_label.config(text="Optimizing...", fg=self.colors['warning'])
        
        def optimize():
            try:
                if self.os_type == "Windows":
                    self.log("🔧 Flushing DNS cache...")
                    subprocess.run(["ipconfig", "/flushdns"], capture_output=True, check=True)
                    
                    self.log("🔧 Resetting Winsock...")
                    subprocess.run(["netsh", "winsock", "reset"], capture_output=True, check=True)
                    
                    self.log("🔧 Resetting IP stack...")
                    subprocess.run(["netsh", "int", "ip", "reset"], capture_output=True, check=True)
                    
                    self.log("🔧 Releasing IP...")
                    subprocess.run(["ipconfig", "/release"], capture_output=True, check=True)
                    
                    self.log("🔧 Renewing IP...")
                    subprocess.run(["ipconfig", "/renew"], capture_output=True, check=True)
                    
                    self.log("✅ Network optimization completed!")
                    self.log("⚠️ Recommendation: Restart your computer for best results")
                    
                elif self.os_type == "Linux":
                    self.log("🔧 Flushing DNS cache...")
                    subprocess.run(["sudo", "systemd-resolve", "--flush-caches"], capture_output=True)
                    
                    self.log("🔧 Restarting network manager...")
                    subprocess.run(["sudo", "systemctl", "restart", "NetworkManager"], capture_output=True)
                    
                    self.log("✅ Network optimization completed!")
                    
                else:  # macOS
                    self.log("🔧 Flushing DNS cache...")
                    subprocess.run(["sudo", "dscacheutil", "-flushcache"], capture_output=True)
                    subprocess.run(["sudo", "killall", "-HUP", "mDNSResponder"], capture_output=True)
                    
                    self.log("✅ Network optimization completed!")
                
                self.status_label.config(text="Optimized", fg=self.colors['success'])
                messagebox.showinfo("Success", "Network optimization completed!\n\nFor best results, restart your computer.")
                
            except subprocess.CalledProcessError as e:
                self.log(f"❌ Error: {str(e)}")
                self.log("⚠️ Try running this program as Administrator/Root")
                self.status_label.config(text="Error", fg=self.colors['danger'])
                messagebox.showerror("Error", "Optimization failed. Try running as Administrator.")
            except Exception as e:
                self.log(f"❌ Unexpected error: {str(e)}")
                self.status_label.config(text="Error", fg=self.colors['danger'])
        
        threading.Thread(target=optimize, daemon=True).start()
    
    def optimize_dns(self):
        """Optimize DNS settings by testing multiple DNS servers"""
        self.log("🔍 Testing DNS servers for best performance...")
        self.status_label.config(text="Testing DNS...", fg=self.colors['warning'])
        
        def test_dns():
            dns_servers = {
                "Cloudflare": "1.1.1.1",
                "Google": "8.8.8.8",
                "Quad9": "9.9.9.9",
                "OpenDNS": "208.67.222.222"
            }
            
            results = {}
            
            for name, dns in dns_servers.items():
                self.log(f"Testing {name} ({dns})...")
                ping = self.ping_test(dns)
                if ping:
                    results[name] = ping
                    self.log(f"  ↳ {name}: {ping}ms")
                else:
                    self.log(f"  ↳ {name}: Failed")
            
            if results:
                best_dns = min(results, key=results.get)
                best_ping = results[best_dns]
                
                self.log(f"\n✅ FASTEST DNS: {best_dns} ({best_ping}ms)")
                self.log(f"📝 Recommended DNS: {dns_servers[best_dns]}")
                
                msg = f"Fastest DNS Server Found:\n\n"
                msg += f"🏆 {best_dns}\n"
                msg += f"📡 Ping: {best_ping}ms\n"
                msg += f"🔧 DNS: {dns_servers[best_dns]}\n\n"
                msg += f"To change DNS:\n"
                msg += f"1. Open Network Settings\n"
                msg += f"2. Change DNS to: {dns_servers[best_dns]}\n"
                msg += f"3. (Secondary: 1.0.0.1 for Cloudflare or 8.8.4.4 for Google)"
                
                messagebox.showinfo("DNS Test Results", msg)
                
                self.status_label.config(text="DNS Tested", fg=self.colors['success'])
            else:
                self.log("❌ All DNS tests failed")
                self.status_label.config(text="Test Failed", fg=self.colors['danger'])
                messagebox.showerror("Error", "Could not test DNS servers. Check your internet connection.")
        
        threading.Thread(target=test_dns, daemon=True).start()
    
    def diagnose_connection(self):
        """Diagnose network connection issues"""
        self.log("🔍 Starting connection diagnostics...")
        self.status_label.config(text="Diagnosing...", fg=self.colors['warning'])
        
        def diagnose():
            issues = []
            
            # Test 1: Internet connectivity
            self.log("1️⃣ Testing internet connectivity...")
            ping_google = self.ping_test("8.8.8.8")
            if not ping_google:
                issues.append("❌ Cannot reach internet (8.8.8.8)")
                self.log("  ↳ ❌ FAILED - No internet connection")
            else:
                self.log(f"  ↳ ✅ PASSED - Ping: {ping_google}ms")
            
            # Test 
