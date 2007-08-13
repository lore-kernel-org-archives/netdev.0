From: joe@perches.com
Subject: [PATCH] [478/2many] MAINTAINERS - TOKEN-RING NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:37:19 -0700
Message-ID: <46bffc1f.jeLQtdRi39eTOfu9%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	mikep@linuxtr.net, linux-tr@linuxtr.net,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2075 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966714AbXHMGhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:37:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index fda287c..b5dc1ac 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4539,6 +4539,8 @@ L:	netdev@vger.kernel.org
 L:	linux-tr@linuxtr.net
 W:	http://www.linuxtr.net
 S:	Maintained
+F:	drivers/net/tokenring/
+F:	net/802/tr.c
 
 TOSHIBA ACPI EXTRAS DRIVER
 P:	John Belmonte
