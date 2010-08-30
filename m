From: Simon Horman <horms@verge.net.au>
Subject: [patch net-next] net: fix datapath typo
Date: Mon, 30 Aug 2010 13:34:18 +0900
Message-ID: <20100830043418.GB24373@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41056 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573Ab0H3EeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 00:34:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Ben Pfaff <blp@nicira.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

This time, with the patch

Index: net-next-2.6/include/linux/if.h
===================================================================
--- net-next-2.6.orig/include/linux/if.h	2010-08-30 12:34:51.000000000 +0900
+++ net-next-2.6/include/linux/if.h	2010-08-30 12:35:45.000000000 +0900
@@ -76,7 +76,7 @@
 #define IFF_MACVLAN_PORT	0x4000	/* device used as macvlan port */
 #define IFF_BRIDGE_PORT	0x8000		/* device used as bridge port */
 #define IFF_OVS_DATAPATH	0x10000	/* device used as Open vSwitch
-					 * dapath port */
+					 * datapath port */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002

