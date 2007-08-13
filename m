From: joe@perches.com
Subject: [PATCH] [157/2many] MAINTAINERS - DAVICOM FAST ETHERNET (DMFE)
 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:26:24 -0700
Message-ID: <46bff990.Gtgh0+lBHbcs0YXY%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, tori@unhappy.mine.nu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4188 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966272AbXHMG0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:26:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index bd0fa0e..60bda8d 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1534,6 +1534,8 @@ P:	Tobias Ringstrom
 M:	tori@unhappy.mine.nu
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	Documentation/networking/dmfe.txt
+F:	drivers/net/tulip/dmfe.c
 
 DMA GENERIC OFFLOAD ENGINE SUBSYSTEM
 P:	Shannon Nelson
