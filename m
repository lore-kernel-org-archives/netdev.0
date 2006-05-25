From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] pci_ids: add new device ids
Date: Thu, 25 May 2006 13:10:38 -0400
Message-ID: <4475E50E.8060903@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070307070409040903030509"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:5656 "EHLO
	HQEMGATE01.nvidia.com") by vger.kernel.org with ESMTP
	id S1030388AbWEYUG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 16:06:57 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070307070409040903030509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds new device ids for MCP61 and MCP65 chips.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070307070409040903030509
Content-Type: text/plain;
 name="patch-mcp61-mcp65-ids"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-mcp61-mcp65-ids"

--- a/include/linux/pci_ids.h	2006-05-25 13:02:56.000000000 -0400
+++ b/include/linux/pci_ids.h	2006-05-25 13:03:09.000000000 -0400
@@ -1182,6 +1182,14 @@
 #define PCI_DEVICE_ID_NVIDIA_QUADRO_FX_1100         0x034E
 #define PCI_DEVICE_ID_NVIDIA_NVENET_14              0x0372
 #define PCI_DEVICE_ID_NVIDIA_NVENET_15              0x0373
+#define PCI_DEVICE_ID_NVIDIA_NVENET_16              0x03E5
+#define PCI_DEVICE_ID_NVIDIA_NVENET_17              0x03E6
+#define PCI_DEVICE_ID_NVIDIA_NVENET_18              0x03EE
+#define PCI_DEVICE_ID_NVIDIA_NVENET_19              0x03EF
+#define PCI_DEVICE_ID_NVIDIA_NVENET_20              0x0450
+#define PCI_DEVICE_ID_NVIDIA_NVENET_21              0x0451
+#define PCI_DEVICE_ID_NVIDIA_NVENET_22              0x0452
+#define PCI_DEVICE_ID_NVIDIA_NVENET_23              0x0453
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128

--------------070307070409040903030509--
