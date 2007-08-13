From: joe@perches.com
Subject: [PATCH] [184/2many] MAINTAINERS - ETHEREXPRESS-16 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:27:16 -0700
Message-ID: <46bff9c4.pMPQodovpWqf//FD%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, philb@gnu.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4355 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966373AbXHMG13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:27:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 6fe987d..27eb5be 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1774,6 +1774,7 @@ P:	Philip Blundell
 M:	philb@gnu.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/eexpress.*
 
 ETHERNET BRIDGE
 P:	Stephen Hemminger
