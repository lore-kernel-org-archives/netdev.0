From: joe@perches.com
Subject: [PATCH] [5/2many] MAINTAINERS - 3CR990 NETWORK DRIVER
Date: Sun, 12 Aug 2007 23:21:33 -0700
Message-ID: <46bff86d.3nPB+/nZUm72NBI6%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dave@thedillows.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3377 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935796AbXHMGVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:21:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 3fbc13a..30f8ef5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -110,6 +110,7 @@ P:	David Dillow
 M:	dave@thedillows.org
 L:	netdev@vger.kernel.org
 S:	Maintained
+F:	drivers/net/typhoon*
 
 3W-XXXX ATA-RAID CONTROLLER DRIVER
 P:	Adam Radford
