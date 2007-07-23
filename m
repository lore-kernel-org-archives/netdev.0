From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/2] forcedeth: new device ids in pci_ids.h
Date: Sun, 22 Jul 2007 20:43:15 -0400
Message-ID: <46A3F9A3.10508@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050903070508030800080108"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:2535 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbXGWUxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 16:53:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050903070508030800080108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch contains new device ids for MCP73 chipset.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------050903070508030800080108
Content-Type: text/plain;
 name="patch-device-ids-mcp73"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-device-ids-mcp73"

--- old/include/linux/pci_ids.h	2007-07-22 18:57:26.000000000 -0400
+++ new/include/linux/pci_ids.h	2007-07-22 18:57:11.000000000 -0400
@@ -1223,6 +1223,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_25              0x054D
 #define PCI_DEVICE_ID_NVIDIA_NVENET_26              0x054E
 #define PCI_DEVICE_ID_NVIDIA_NVENET_27              0x054F
+#define PCI_DEVICE_ID_NVIDIA_NVENET_28              0x07DC
+#define PCI_DEVICE_ID_NVIDIA_NVENET_29              0x07DD
+#define PCI_DEVICE_ID_NVIDIA_NVENET_30              0x07DE
+#define PCI_DEVICE_ID_NVIDIA_NVENET_31              0x07DF
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP67_IDE       0x0560
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP73_IDE       0x056C
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP77_IDE       0x0759

--------------050903070508030800080108--
