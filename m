From: Chas Williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: Remove modules.txt in drivers/atm/Kconfig (Nicolas Kaiser <nikai@nikai.net>)
Date: Mon, 29 Sep 2003 10:04:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309291404.h8TE4qkT027322@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks


[ATM]: Remove modules.txt in drivers/atm/Kconfig (Nicolas Kaiser <nikai@nikai.net>)

--- trivial-2.6.0-test5-bk10/drivers/atm/Kconfig.orig	2003-09-24 12:27:31.000000000 +1000
+++ trivial-2.6.0-test5-bk10/drivers/atm/Kconfig	2003-09-24 12:27:31.000000000 +1000
@@ -32,9 +32,8 @@
 	  The driver works with MMF (-MF or ...F) and UTP-5 (-U5 or ...D)
 	  adapters.
 
-	  This driver is also available as a module.  If you want to compile
-	  it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  The module will be called eni.
+	  To compile this driver as a module, choose M here: the module will
+	  be called eni.
 
 config ATM_ENI_DEBUG
 	bool "Enable extended debugging"
@@ -138,10 +137,8 @@
 	  Driver for the Fujitsu FireStream 155 (MB86697) and
 	  FireStream 50 (MB86695) ATM PCI chips.
 
-	  This driver is also available as a module.  If you want to compile
-	  it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  The module will be called
-	  firestream.
+	  To compile this driver as a module, choose M here: the module will
+	  be called firestream.
 
 config ATM_ZATM
 	tristate "ZeitNet ZN1221/ZN1225"
@@ -150,9 +147,8 @@
 	  Driver for the ZeitNet ZN1221 (MMF) and ZN1225 (UTP-5) 155 Mbps ATM
 	  adapters.
 
-	  This driver is also available as a module.  If you want to compile
-	  it as a module, say M here and read
-	  <file:Documentation/modules.txt>.  The module will be called zatm.
+	  To compile this driver as a module, choose M here: the module will
+	  be called zatm.
 
 config ATM_ZATM_DEBUG
 	bool "Enable extended debugging"
@@ -176,10 +172,8 @@
 	  25 and for 155 Mbps, including IDT cards and the Fore ForeRunnerLE
 	  series. Say Y if you have one of those.
 
-	  This driver is also available as a module.  If you want to compile
-	  it as a module, say M here and read
-	  <file:Documentation/modules.txt>. The module will be called
-	  nicstar.
+	  To compile this driver as a module, choose M here: the module will
+	  be called nicstar.
 
 config ATM_NICSTAR_USE_SUNI
 	bool "Use suni PHY driver (155Mbps)"
@@ -209,9 +203,8 @@
 	help
 	  Driver for the IDT 77252 ATM PCI chips.
 
-	  This driver is also available as a module.  If you want to compile
-	  it as a module, say M here and read
-	  <file:Documentation/modules.txt>. The module will be called idt77252
+	  To compile this driver as a module, choose M here: the module will
+	  be called idt77252.
 
 config ATM_IDT77252_DEBUG
 	bool "Enable debugging messages"
