From: <Bryan.Whitehead@microchip.com>
Subject: [PATCH net-next 0/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 19:47:51 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264406F6034@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:39882 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753325AbdHKTsI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 15:48:08 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan Whitehead <Bryan.Whitehead@microchip.com>

Add Microchip LAN743X PCIe 3.1 Gigabit Ethernet Controller Driver

Bryan Whitehead (3):
  Add LAN743X driver
  Add LAN743X to Kconfig and Makefile
  Add LAN743X to MAINTAINER list

 MAINTAINERS                              |    7 +
 drivers/net/ethernet/microchip/Kconfig   |   10 +-
 drivers/net/ethernet/microchip/Makefile  |    1 +
 drivers/net/ethernet/microchip/lan743x.c | 6842 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/microchip/lan743x.h | 1417 +++++++
 5 files changed, 8276 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/microchip/lan743x.c
 create mode 100644 drivers/net/ethernet/microchip/lan743x.h

-- 
2.7.4
