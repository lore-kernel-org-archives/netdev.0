From: joe@perches.com
Subject: [PATCH] [520/2many] MAINTAINERS - USB USBNET DRIVER FRAMEWORK
Date: Sun, 12 Aug 2007 23:39:02 -0700
Message-ID: <46bffc86.zUTp+OkLXhZdln2W%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dbrownell@users.sourceforge.net,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2344 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965881AbXHMGjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:39:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index c670797..4dba8ee 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4916,6 +4916,7 @@ M:	dbrownell@users.sourceforge.net
 L:	netdev@vger.kernel.org
 W:	http://www.linux-usb.org/usbnet
 S:	Maintained
+F:	drivers/net/usb/usbnet.*
 
 USB W996[87]CF DRIVER
 P:	Luca Risolia
