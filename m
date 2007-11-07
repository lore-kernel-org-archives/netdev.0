From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth new mcp79 device ids
Date: Wed, 07 Nov 2007 16:58:09 -0500
Message-ID: <473234F1.9000109@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070504070904080901010902"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:7458 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760727AbXKHWtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 17:49:46 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070504070904080901010902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds new device ids for mcp79 devices.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070504070904080901010902
Content-Type: text/plain;
 name="patch-pci-ids-mcp79"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-pci-ids-mcp79"

--- old/include/linux/pci_ids.h	2007-11-07 14:14:01.000000000 -0500
+++ new/include/linux/pci_ids.h	2007-11-07 14:13:53.000000000 -0500
@@ -1237,6 +1237,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_33              0x0761
 #define PCI_DEVICE_ID_NVIDIA_NVENET_34              0x0762
 #define PCI_DEVICE_ID_NVIDIA_NVENET_35              0x0763
+#define PCI_DEVICE_ID_NVIDIA_NVENET_36              0x0AB0
+#define PCI_DEVICE_ID_NVIDIA_NVENET_37              0x0AB1
+#define PCI_DEVICE_ID_NVIDIA_NVENET_38              0x0AB2
+#define PCI_DEVICE_ID_NVIDIA_NVENET_39              0x0AB3
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128

--------------070504070904080901010902--
