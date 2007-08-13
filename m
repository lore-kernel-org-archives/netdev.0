From: joe@perches.com
Subject: [PATCH] [530/2many] MAINTAINERS - VIA VELOCITY NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:39:20 -0700
Message-ID: <46bffc98.lHe88PoL/SR8qHEB%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2376 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967455AbXHMGjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:39:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 392d697..be3d826 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5002,6 +5002,7 @@ P:	Francois Romieu
 M:	romieu@fr.zoreil.com
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	/drivers/net/via-velocity.*
 
 UCLINUX (AND M68KNOMMU)
 P:	Greg Ungerer
