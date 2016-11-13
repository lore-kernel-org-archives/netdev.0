From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Gigabit ethernet driver for Alacritechs SLIC devices
Date: Sun, 13 Nov 2016 05:47:31 +0100
Message-ID: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is a rework of the slicoss gigabit ethernet driver from Alacritech 
that is currently part of the staging area. The driver is supposed to 
support Mojave, Oasis and Kalahari cards, for both copper and fiber.

If this code is accepted the staging version can be removed (as Greg 
told me by email, he would do this himself so this is not part of these
patches).

The driver is tested on a SEN2104ET card (4 Port PCIe copper).

Regards,
Lino
