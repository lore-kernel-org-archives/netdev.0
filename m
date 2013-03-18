From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] libertas: drop maintainership
Date: Mon, 18 Mar 2013 11:48:41 -0500
Message-ID: <1363625321.1597.28.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Daniel Drake <dsd@laptop.org>,
	Bing Zhao <bzhao@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab3CRQrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 12:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would be better maintained by somebody who actualy has time for it.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
Daniel?  Bing? :)

I'm quite happy to ACK somebody else picking libertas up, and I'm also
happy to investigate how to send my hardware cache to the new
maintainer.  (usb8388 dev modules, some CF8385s, some sd8686s, etc).
Also happy to forward along the libertas-dev moderator password.

diff --git a/MAINTAINERS b/MAINTAINERS
index c08411b..2146279 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5042,12 +5042,6 @@ L:	netdev@vger.kernel.org
 S:	Maintained
 F:	drivers/net/ethernet/marvell/sk*
 
-MARVELL LIBERTAS WIRELESS DRIVER
-M:	Dan Williams <dcbw@redhat.com>
-L:	libertas-dev@lists.infradead.org
-S:	Maintained
-F:	drivers/net/wireless/libertas/
-
 MARVELL MV643XX ETHERNET DRIVER
 M:	Lennert Buytenhek <buytenh@wantstofly.org>
 L:	netdev@vger.kernel.org
