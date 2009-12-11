From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH]Transfering-maintainership-of-cdc-ether
Date: Fri, 11 Dec 2009 23:33:08 +0100
Message-ID: <200912112333.09074.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:58370 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755764AbZLKWcw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 17:32:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 128a6479f06fdaa71ec75efe145a10c1309d13a4 Mon Sep 17 00:00:00 2001
From: Oliver Neukum <oliver@neukum.org>
Date: Fri, 11 Dec 2009 23:29:42 +0100
Subject: [PATCH] Transfering maintainership of cdc-ether

Oliver Neukum takes over from Greg KH

Signed-off-by: Oliver Neukum <oliver@neukum.org>
---
 MAINTAINERS |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index ea781c1..04390e9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5391,10 +5391,9 @@ S:	Supported
 F:	drivers/block/ub.c
 
 USB CDC ETHERNET DRIVER
-M:	Greg Kroah-Hartman <greg@kroah.com>
+M:	Oliver Neukum <oliver@neukum.name>
 L:	linux-usb@vger.kernel.org
 S:	Maintained
-W:	http://www.kroah.com/linux-usb/
 F:	drivers/net/usb/cdc_*.c
 F:	include/linux/usb/cdc.h
 
-- 
1.6.4.2

