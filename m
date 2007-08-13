From: joe@perches.com
Subject: [PATCH] [308/2many] MAINTAINERS - MACVLAN DRIVER
Date: Sun, 12 Aug 2007 23:31:40 -0700
Message-ID: <46bffacc.oLbMW/xdn72uEebz%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1088 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967001AbXHMGb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:31:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 07fb80f..b4d6651 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2966,6 +2966,8 @@ P:	Patrick McHardy
 M:	kaber@trash.net
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/macvlan.c
+F:	include/linux/if_macvlan.h
 
 MARVELL YUKON / SYSKONNECT DRIVER
 P:	Mirko Lindner
