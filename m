From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] MAINTAINERS: update DMFE and wireless drivers mailing list
Date: Wed, 7 Feb 2007 15:52:36 -0800
Message-ID: <20070207155236.72f0b18c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, tori@unhappy.mine.nu,
	jgarzik <jgarzik@pobox.com>, davem@davemloft.net,
	akpm <akpm@osdl.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50993 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422821AbXBGX67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 18:58:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

List netdev as the mailing list for DMFE (network driver)
instead of lkml.

List linux-wireless as the mailing list for wireless network drivers.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 MAINTAINERS |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2620-work.orig/MAINTAINERS
+++ linux-2620-work/MAINTAINERS
@@ -1096,7 +1096,7 @@ S:	Supported
 DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
 P:	Tobias Ringstrom
 M:	tori@unhappy.mine.nu
-L:	linux-kernel@vger.kernel.org
+L:	netdev@vger.kernel.org
 S:	Maintained
 
 DOCBOOK FOR DOCUMENTATION
@@ -2343,7 +2343,7 @@ S:	Maintained
 NETWORKING [WIRELESS]
 P:	John W. Linville
 M:	linville@tuxdriver.com
-L:	netdev@vger.kernel.org
+L:	linux-wireless@vger.kernel.org
 T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
 S:	Maintained
 
