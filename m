From: Jing Huang <huangj@brocade.com>
Subject: [PATCH] bna: add readme file
Date: Fri, 27 Jan 2012 16:56:45 -0800
Message-ID: <1327712205-17609-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:46856 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab2A1Bnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 20:43:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds bna driver readme file to Documentation/networking.

Signed-off-by: Jing Huang <huangj@brocade.com>
---
 Documentation/networking/bna.txt |   72 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 72 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/bna.txt

diff --git a/Documentation/networking/bna.txt b/Documentation/networking/bna.txt
new file mode 100644
index 0000000..505fc49
--- /dev/null
+++ b/Documentation/networking/bna.txt
@@ -0,0 +1,72 @@
+Linux Driver for Brocade 10G PCIe Ethernet Adapters
+
+
+Supported Hardware
+------------------
+
+bna 3.0.2.2 driver supports all Brocade FC/FCOE adapters. Below is a list of
+adapter models with corresponding PCIIDs.
+
+	PCIID			Model
+
+	1657:0014:1657:0014	1010 10Gbps single port CNA - LL
+	1657:0014:1657:0014	1020 10Gbps dual port CNA - LL
+	1657:0014:1657:0014	1007 10Gbps dual port CNA - LL
+	1657:0014:1657:0014	1741 10Gbps dual port CNA - LL
+
+	1657:0022:1657:0023	1860 10Gbps CNA - LL
+	1657:0022:1657:0023	1860 10Gbps NIC - LL
+
+
+Firmware download
+-----------------
+
+The latest Firmware package for 3.0.2.2 bna driver can be found at:
+
+http://www.brocade.com/services-support/drivers-downloads/adapters/Linux.page
+
+and then click following respective util package link:
+
+	Version			Link 
+
+	v3.0.0.0	Linux Adapter Firmware package for RHEL 6.2, SLES 11SP2
+
+
+Configuration & Management utility download
+-------------------------------------------
+
+The latest driver configuration & management utility for 3.0.2.2 bna driver can
+be found at: 
+
+http://www.brocade.com/services-support/drivers-downloads/adapters/Linux.page
+
+and then click following respective util package link:
+
+	Version			Link 
+
+	v3.0.2.0	Linux Adapter Util package for RHEL 6.2, SLES 11SP2
+
+
+Documentation
+-------------
+
+The latest Administration's Guide, Installation and Reference Manual,
+Troubleshooting Guide, and Release Notes for the corresponding out-of-box
+driver can be found at:
+
+http://www.brocade.com/services-support/drivers-downloads/adapters/Linux.page
+
+and use the following inbox and out-of-box driver version mapping to find
+the corresponding documentation:
+
+	Inbox Version		Out-of-box Version 
+
+	v3.0.2.2		v3.0.0.0
+
+
+Support
+-------
+
+For general product and support info, go to the Brocade website at:
+
+http://www.brocade.com/services-support/index.page
-- 
1.6.5.2
