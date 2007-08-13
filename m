From: joe@perches.com
Subject: [PATCH] [4/2many] MAINTAINERS - 3C505 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:21:31 -0700
Message-ID: <46bff86b.6CRikM1p0kIYHkxB%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, philb@gnu.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3366 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761251AbXHMGVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:21:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index f74f7d5..3fbc13a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -103,6 +103,7 @@ P:	Philip Blundell
 M:	philb@gnu.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/3c505*
 
 3CR990 NETWORK DRIVER
 P:	David Dillow
