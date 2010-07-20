From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4vf: add maintainer entry for cxgb4vf
Date: Tue, 20 Jul 2010 08:59:56 -0700
Message-ID: <201007200859.57111.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:5428 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754026Ab0GTQHN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 12:07:13 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6KG7CLu017820
	for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 09:07:13 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 7710873beb494b46333fdf9841b4a117bdb66a5a Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Mon, 19 Jul 2010 17:55:33 -0700
Subject: [PATCH net-next 3/3] cxgb4vf: add maintainer entry for cxgb4vf

Adding myself as the official maintainer of the Chelsio T4 Virtual function
Driver (cxgb4vf).

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c05b499..aa73c9a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1767,6 +1767,13 @@ W:	http://www.openfabrics.org
 S:	Supported
 F:	drivers/infiniband/hw/cxgb4/
 
+CXGB4VF ETHERNET DRIVER (CXGB4VF)
+M:	Casey Leedom <leedom@chelsio.com>
+L:	netdev@vger.kernel.org
+W:	http://www.chelsio.com
+S:	Supported
+F:	drivers/net/cxgb4vf/
+
 CYBERPRO FB DRIVER
 M:	Russell King <linux@arm.linux.org.uk>
 L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
-- 
1.7.0.4

