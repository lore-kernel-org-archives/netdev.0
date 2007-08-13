From: joe@perches.com
Subject: [PATCH] [3/2many] MAINTAINERS - 3C359 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:21:29 -0700
Message-ID: <46bff869.Zymd4IfBmaZBPKxx%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	mikep@linuxtr.net, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3364 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbXHMGVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:21:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 0d7f856..f74f7d5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -94,9 +94,9 @@ F: Files and directories with wildcard patterns.
 P:	Mike Phillips
 M:	mikep@linuxtr.net
 L:	netdev@vger.kernel.org
-L:	linux-tr@linuxtr.net
 W:	http://www.linuxtr.net
 S:	Maintained
+F:	drivers/net/tokenring/3c359*
 
 3C505 NETWORK DRIVER
 P:	Philip Blundell
