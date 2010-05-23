From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 053/199] Documentation/isdn/README.HiSax: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:17 +0200
Message-ID: <1274644226-23612-3-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:8538 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593Ab0EWTui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 15:50:38 -0400
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation/isdn/README.HiSax:62: ERROR: trailing whitespace
Documentation/isdn/README.HiSax:191: ERROR: trailing whitespace
Documentation/isdn/README.HiSax:192: ERROR: trailing whitespace
Documentation/isdn/README.HiSax:200: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.HiSax |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/isdn/README.HiSax b/Documentation/isdn/README.HiSax
index 031c8d8..de8a9fc 100644
--- a/Documentation/isdn/README.HiSax
+++ b/Documentation/isdn/README.HiSax
@@ -59,7 +59,7 @@ Traverse Technologie NETjet PCI S0 card and NETspider U card
 Ovislink ISDN sc100-p card (NETjet driver)
 Dr. Neuhaus Niccy PnP/PCI
 Siemens I-Surf 1.0
-Siemens I-Surf 2.0 (with IPAC, try type 12 asuscom) 
+Siemens I-Surf 2.0 (with IPAC, try type 12 asuscom)
 ACER P10
 HST Saphir
 Berkom Telekom A4T
@@ -188,8 +188,8 @@ Card types:
    27   AVM PnP (Fritz!PnP)      irq, io  (from isapnp setup)
    27   AVM PCI (Fritz!PCI)      no parameter
    28   Sedlbauer Speed Fax+     irq, io (from isapnp setup)
-   29	Siemens I-Surf 1.0       irq, io, memory (from isapnp setup)   
-   30	ACER P10                 irq, io (from isapnp setup)   
+   29	Siemens I-Surf 1.0       irq, io, memory (from isapnp setup)
+   30	ACER P10                 irq, io (from isapnp setup)
    31	HST Saphir               irq, io
    32	Telekom A4T              none
    33	Scitel Quadro		 subcontroller (4*S0, subctrl 1...4)
@@ -197,7 +197,7 @@ Card types:
    34	Gazel ISDN cards (PCI)   none
    35	HFC 2BDS0 PCI            none
    36	W6692 based PCI cards    none
-   37	HFC 2BDS0 S+, SP         irq,io 
+   37	HFC 2BDS0 S+, SP         irq,io
    38	NETspider U PCI card     none
    39	HFC 2BDS0 SP/PCMCIA      irq,io (set with cardmgr)
    40   hotplug interface
-- 
1.7.1.251.gf80a2

