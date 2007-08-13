From: joe@perches.com
Subject: [PATCH] [492/2many] MAINTAINERS - USB DAVICOM DM9601 DRIVER
Date: Sun, 12 Aug 2007 23:38:04 -0700
Message-ID: <46bffc4c.w7oFuPSxHvT0GnSB%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jacmet@sunsite.dk,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2170 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S939240AbXHMGiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:38:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 8f496de..b7498bf 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4662,6 +4662,7 @@ M:	jacmet@sunsite.dk
 L:	netdev@vger.kernel.org
 W:	http://www.linux-usb.org/usbnet
 S:	Maintained
+F:	drivers/net/usb/dm9601.c
 
 USB EHCI DRIVER
 P:	David Brownell
