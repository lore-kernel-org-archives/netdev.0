From: Kyle McMartin <kyle@mcmartin.ca>
Subject: [PATCH] MAINTAINERS: remove me from tulip
Date: Thu, 9 Dec 2010 14:50:08 -0500
Message-ID: <20101209195008.GV25668@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, grundler@parisc-linux.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45554 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920Ab0LITuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 14:50:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was a nice idea, but -ENOTIME and -ENOHW. I never got around to doing
a lot of the clean up that I intended to.

Signed-off-by: Kyle McMartin <kyle@mcmartin.ca>
---
diff --git a/MAINTAINERS b/MAINTAINERS
index 1a1c27b..a54a738 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5932,7 +5932,6 @@ F:	include/linux/tty.h
 
 TULIP NETWORK DRIVERS
 M:	Grant Grundler <grundler@parisc-linux.org>
-M:	Kyle McMartin <kyle@mcmartin.ca>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/tulip/
