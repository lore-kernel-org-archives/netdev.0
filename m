From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] new pci device id
Date: Tue, 02 Jun 2009 15:18:34 -0400
Message-ID: <4A257B0A.8060805@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050007000102040504000303"
To: Manfred Spraul <manfred@colorfullife.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:15529 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbZFCAvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 20:51:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050007000102040504000303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a new NVIDIA ethernet device id for the MCP89 chipset.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------050007000102040504000303
Content-Type: text/plain;
 name="patch-pci-ids-mcp89"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-pci-ids-mcp89"

--- old/include/linux/pci_ids.h	2009-06-02 14:36:50.000000000 -0400
+++ new/include/linux/pci_ids.h	2009-06-02 14:54:08.000000000 -0400
@@ -1287,6 +1287,7 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_37              0x0AB1
 #define PCI_DEVICE_ID_NVIDIA_NVENET_38              0x0AB2
 #define PCI_DEVICE_ID_NVIDIA_NVENET_39              0x0AB3
+#define PCI_DEVICE_ID_NVIDIA_NVENET_40              0x0D7D
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128

--------------050007000102040504000303--
