From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] MAINTAINERS: no DMFE maintainer
Date: Fri, 9 Feb 2007 14:31:06 -0800
Message-ID: <20070209143106.9dc30c9b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, tori@unhappy.mine.nu
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:13085 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbXBIWeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 17:34:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Tobias wrote that he no longer maintains this driver and requested
to be removed from MAINTAINERS.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 MAINTAINERS |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- linux-2.6.20-git5.orig/MAINTAINERS
+++ linux-2.6.20-git5/MAINTAINERS
@@ -1112,10 +1112,8 @@ T:	git kernel.org:/pub/scm/linux/kernel/
 S:	Supported
 
 DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
-P:	Tobias Ringstrom
-M:	tori@unhappy.mine.nu
 L:	netdev@vger.kernel.org
-S:	Maintained
+S:	Orphan
 
 DOCBOOK FOR DOCUMENTATION
 P:	Randy Dunlap
