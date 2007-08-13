From: joe@perches.com
Subject: [PATCH] [195/2many] MAINTAINERS - FREESCALE QUICC ENGINE UCC
 ETHERNET DRIVER
Date: Sun, 12 Aug 2007 23:27:51 -0700
Message-ID: <46bff9e7.He8/+5xXuJGrnQHg%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org, linux-kernel@vger.kernel.org,
	leoli@freescale.com, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4431 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966610AbXHMG2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:28:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 944316a..35f1636 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1876,6 +1876,7 @@ M:	leoli@freescale.com
 L:	netdev@vger.kernel.org
 L:	linuxppc-embedded@ozlabs.org
 S:	Maintained
+F:	drivers/net/ucc_geth*
 
 FILE LOCKING (flock() and fcntl()/lockf())
 P:	Matthew Wilcox
