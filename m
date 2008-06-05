From: Dale Farnsworth <dale@farnsworth.org>
Subject: [PATCH] New maintainer for the mv643xx_eth driver
Date: Thu, 5 Jun 2008 06:10:51 -0700
Message-ID: <20080605131051.GA8019@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>,
	mlachwani@mvista.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:37863 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754630AbYFENLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 09:11:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
With Lennert Buytenhek's recent improvements to the mv643xx_eth
driver, it's become evident that he's committed to maintaining
it.  Lennert has consented to taking over maintainership of the
driver.  I'm pleased to pass the baton to someone who is as
capable and motivated as Lennert.

Also, since Manish hasn't been active on the driver during the
time that I've been the maintainer, we'll remove him as well.

It's been fun.

Dale Farnsworth

 MAINTAINERS |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 46fa179..83b0242 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2690,12 +2690,10 @@ L:	libertas-dev@lists.infradead.org
 S:	Maintained
 
 MARVELL MV643XX ETHERNET DRIVER
-P:	Dale Farnsworth
-M:	dale@farnsworth.org
-P:	Manish Lachwani
-M:	mlachwani@mvista.com
+P:	Lennert Buytenhek
+M:	kernel@wantstofly.org
 L:	netdev@vger.kernel.org
-S:	Odd Fixes for 2.4; Maintained for 2.6.
+S:	Maintained
 
 MATROX FRAMEBUFFER DRIVER
 P:	Petr Vandrovec
-- 
1.5.5.1
