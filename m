From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH v2] libertas: drop maintainership
Date: Tue, 26 Mar 2013 14:40:51 -0500
Message-ID: <1364326851.1514.49.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Daniel Drake <dsd@laptop.org>,
	Bing Zhao <bzhao@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754247Ab3CZTkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 15:40:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would be better maintained by somebody who actualy has time for it.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
I'm quite happy to ACK somebody else picking libertas up, and I'm also
happy to investigate how to send my hardware cache to the new
maintainer.  (usb8388 dev modules, some CF8385s, some sd8686s, etc).
Also happy to forward along the libertas-dev moderator password.

diff --git a/MAINTAINERS b/MAINTAINERS
index c08411b..e2e32d9 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5043,9 +5043,8 @@ S:	Maintained
 F:	drivers/net/ethernet/marvell/sk*
 
 MARVELL LIBERTAS WIRELESS DRIVER
-M:	Dan Williams <dcbw@redhat.com>
 L:	libertas-dev@lists.infradead.org
-S:	Maintained
+S:	Orphan
 F:	drivers/net/wireless/libertas/
 
 MARVELL MV643XX ETHERNET DRIVER
