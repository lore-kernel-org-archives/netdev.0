From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skge, sky2, et all. gplv2 only
Date: Sun, 22 Oct 2006 20:16:57 -0700
Message-ID: <20061022201657.2c458632@dads-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40160 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751300AbWJWDRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2006 23:17:19 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't want my code to downgraded to GPLv3 because of
cut-n-pasted the comments. These files which I hold copyright
on were started before it was clear what GPLv3 was going to be.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.orig/drivers/net/irda/stir4200.c	2006-10-22 20:12:25.000000000 -0700
+++ linux-2.6/drivers/net/irda/stir4200.c	2006-10-22 20:12:33.000000000 -0700
@@ -15,8 +15,7 @@
 *
 *	This program is free software; you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
-*	the Free Software Foundation; either version 2 of the License, or
-*	(at your option) any later version.
+*	the Free Software Foundation; either version 2 of the License.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
--- linux-2.6.orig/drivers/net/skge.c	2006-10-22 20:11:36.000000000 -0700
+++ linux-2.6/drivers/net/skge.c	2006-10-22 20:11:50.000000000 -0700
@@ -11,8 +11,7 @@
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
+ * the Free Software Foundation; either version 2 of the License.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
--- linux-2.6.orig/drivers/net/sky2.c	2006-10-22 20:11:14.000000000 -0700
+++ linux-2.6/drivers/net/sky2.c	2006-10-22 20:11:31.000000000 -0700
@@ -10,8 +10,7 @@
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
+ * the Free Software Foundation; either version 2 of the License.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
--- linux-2.6.orig/net/sched/sch_netem.c	2006-10-22 20:12:04.000000000 -0700
+++ linux-2.6/net/sched/sch_netem.c	2006-10-22 20:12:11.000000000 -0700
@@ -4,7 +4,7 @@
  * 		This program is free software; you can redistribute it and/or
  * 		modify it under the terms of the GNU General Public License
  * 		as published by the Free Software Foundation; either version
- * 		2 of the License, or (at your option) any later version.
+ * 		2 of the License.
  *
  *  		Many of the algorithms and ideas for this came from
  *		NIST Net which is not copyrighted. 
