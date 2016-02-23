From: Murali Karicheri <m-karicheri2@ti.com>
Subject: PCIe 1Gbps NIC card with Linux driver support
Date: Tue, 23 Feb 2016 16:07:11 -0500
Message-ID: <56CCC9FF.4080003@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	<shuchen@realtek.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:52825 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279AbcBWVHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 16:07:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

I have to integrate and test a PCIe RC on one of our SoC using a 1Gpbs PCIe NIC card that has driver support available 
in v4.4.x kernel. Can someone recommend one? I see few listed below which seems to have driver. I have indicated the
driver I could find in the kernel source tree. If the driver is listed incorrectly, please let me know
as well.

Thanks.

RealTek http://www.amazon.com/RTL8169-Gigabit-Desktop-Network-1000Mbps/dp/B00NQ2J9EW/ref=sr_1_12?ie=UTF8&qid=1456260434&sr=8-12&keywords=realtek+pci+express+ethernet+card
driver: drivers/net/ethernet/realtek/r8169.c

RealTek: http://www.amazon.com/Realtek-RTL8111C-Ethernet-Interface-SOFTWARE/dp/B007MWYCG2/ref=sr_1_8?ie=UTF8&qid=1456258852&sr=8-8&keywords=pci+express+ethernet+card
driver: drivers/net/ethernet/realtek/r8169.c

realTek:http://www.amazon.com/Gigabit-Ethernet-Express-Network-Controller/dp/B00O1TXSZU/ref=sr_1_14?ie=UTF8&qid=1456258852&sr=8-14&keywords=pci+express+ethernet+card
driver: drivers/net/ethernet/realtek/r8169.c

Broadcom: http://www.amazon.com/SEDNA-Server-Broadcom-BCM5721-Support/dp/B00V0S7QGM/ref=sr_1_2?ie=UTF8&qid=1456260907&sr=8-2&keywords=1g+PCIe+nic
driver: drivers/net/ethernet/broadcom/tg3.c

Broadcom: http://www.amazon.com/Broadcom-BCM5751-Netxtreme-Ethernet-SOFTWARE/dp/B005NX1DAK/ref=sr_1_15?ie=UTF8&qid=1456258852&sr=8-15&keywords=pci+express+ethernet+card
driver: drivers/net/ethernet/broadcom/tg3.c

-- 
Murali Karicheri
Linux Kernel, Keystone
