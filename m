From: joe@perches.com
Subject: [PATCH] [506/2many] MAINTAINERS - USB RTL8150 DRIVER
Date: Sun, 12 Aug 2007 23:38:32 -0700
Message-ID: <46bffc68.ob7E9N2RUcGCVFrT%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, petkan@users.sourceforge.net,
	netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2237 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763869AbXHMGiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2007 02:38:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 02bb359..25df49f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4781,6 +4781,7 @@ L:	linux-usb-devel@lists.sourceforge.net
 L:	netdev@vger.kernel.org
 W:	http://pegasus2.sourceforge.net/
 S:	Maintained
+F:	drivers/net/usb/rtl8150.c
 
 USB SE401 DRIVER
 P:	Jeroen Vreeken
