From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 1/8] ipg: remove old contact information
Date: Fri, 23 Nov 2007 10:18:02 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231017410.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbXKWISG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:18:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

Remove old comment as up-to-date contact information is in MAINTAINERS.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.h |   12 ------------
 1 file changed, 12 deletions(-)

Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -1,20 +1,8 @@
 /*
- *
- * ipg.h
- *
  * Include file for Gigabit Ethernet device driver for Network
  * Interface Cards (NICs) utilizing the Tamarack Microelectronics
  * Inc. IPG Gigabit or Triple Speed Ethernet Media Access
  * Controller.
- *
- * Craig Rich
- * Sundance Technology, Inc.
- * 1485 Saratoga Avenue
- * Suite 200
- * San Jose, CA 95129
- * 408 873 4117
- * www.sundanceti.com
- * craig_rich@sundanceti.com
  */
 #ifndef __LINUX_IPG_H
 #define __LINUX_IPG_H
