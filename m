From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth: add new NVIDIA pci ids
Date: Mon, 30 Oct 2006 17:37:48 -0500
Message-ID: <45467EBC.2020709@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050408090503080906070301"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:10275 "EHLO
	HQEMGATE02.nvidia.com") by vger.kernel.org with ESMTP
	id S1161371AbWJ3S4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:56:38 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050408090503080906070301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds pci device ids for the NVIDIA MCP67 chip.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------050408090503080906070301
Content-Type: text/plain;
 name="patch_pci_ids_mcp67"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_pci_ids_mcp67"

--- a/include/linux/pci_ids.h	2006-10-30 17:22:09.000000000 -0500
+++ b/include/linux/pci_ids.h	2006-10-30 17:22:17.000000000 -0500
@@ -1213,6 +1213,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_21              0x0451
 #define PCI_DEVICE_ID_NVIDIA_NVENET_22              0x0452
 #define PCI_DEVICE_ID_NVIDIA_NVENET_23              0x0453
+#define PCI_DEVICE_ID_NVIDIA_NVENET_24              0x054C
+#define PCI_DEVICE_ID_NVIDIA_NVENET_25              0x054D
+#define PCI_DEVICE_ID_NVIDIA_NVENET_26              0x054E
+#define PCI_DEVICE_ID_NVIDIA_NVENET_27              0x054F
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128

--------------050408090503080906070301--
