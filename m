From: joe@perches.com
Subject: [PATCH] [459/2many] MAINTAINERS - SPIDERNET NETWORK DRIVER for
 CELL
Date: Sun, 12 Aug 2007 23:36:42 -0700
Message-ID: <46bffbfa.6q67BtSh8n+UV4q4%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linas@austin.ibm.com,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1978 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967197AbXHMGg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:36:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index b616562..fa8fb1c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4377,6 +4377,9 @@ P:	Linas Vepstas
 M:	linas@austin.ibm.com
 L:	netdev@vger.kernel.org
 S:	Supported
+F:	Documentation/networking/spider_net.txt
+F:	arch/powerpc/platforms/cell/spider-pic.c
+F:	drivers/net/spider_net*
 
 SRM (Alpha) environment access
 P:	Jan-Benedict Glaw
