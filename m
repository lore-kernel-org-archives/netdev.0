From: joe@perches.com
Subject: [PATCH] [200/2many] MAINTAINERS - FRAME RELAY DLCI/FRAD (Sangoma
 drivers too)
Date: Sun, 12 Aug 2007 23:28:00 -0700
Message-ID: <46bff9f0.2+YFw2HvxZ7PElf8%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	mike.mclagan@linux.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4441 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966624AbXHMG2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:28:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 1e7e562..a6a9366 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1921,6 +1921,8 @@ P:	Mike McLagan
 M:	mike.mclagan@linux.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/wan/dlci.c
+F:	drivers/net/wan/sdla.c
 
 FREEVXFS FILESYSTEM
 P:	Christoph Hellwig
