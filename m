From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH v2 net-next 2/2] MAINTAINERS: add entry for slicoss ethernet driver
Date: Fri, 25 Nov 2016 00:13:05 +0100
Message-ID: <1480029185-14140-3-git-send-email-LinoSanfilippo@gmx.de>
References: <1480029185-14140-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, f.fainelli@gmail.com, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:59921 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752959AbcKXXNx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 18:13:53 -0500
In-Reply-To: <1480029185-14140-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add myself as maintainer for the slicoss ethernet driver.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 MAINTAINERS | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6781a3f..bb9af28 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -562,6 +562,11 @@ T:	git git://linuxtv.org/anttip/media_tree.git
 S:	Maintained
 F:	drivers/media/usb/airspy/
 
+ALACRITECH GIGABIT ETHERNET DRIVER
+M:	Lino Sanfilippo <LinoSanfilippo@gmx.de>
+S:	Maintained
+F:	drivers/net/ethernet/alacritech/*
+
 ALCATEL SPEEDTOUCH USB DRIVER
 M:	Duncan Sands <duncan.sands@free.fr>
 L:	linux-usb@vger.kernel.org
-- 
1.9.1
