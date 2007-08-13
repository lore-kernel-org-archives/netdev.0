From: joe@perches.com
Subject: [PATCH] [310/2many] MAINTAINERS - MARVELL MV643XX ETHERNET DRIVER
Date: Sun, 12 Aug 2007 23:31:44 -0700
Message-ID: <46bffad0.gGobH3kJcTurAxTC%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	mlachwani@mvista.com, linux-kernel@vger.kernel.org,
	dale@farnsworth.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1107 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967013AbXHMGcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:32:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 68b22f3..ce9418a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2990,6 +2990,8 @@ P:	Manish Lachwani
 M:	mlachwani@mvista.com
 L:	netdev@vger.kernel.org
 S:	Odd Fixes for 2.4; Maintained for 2.6.
+F:	drivers/net/mv643xx_eth.*
+F:	include/linux/mv643xx.h
 
 MATROX FRAMEBUFFER DRIVER
 P:	Petr Vandrovec
