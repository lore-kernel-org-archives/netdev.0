From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove obsolete tokenring maintainer information
Date: Fri, 1 Feb 2008 18:19:08 +0200
Message-ID: <20080201161907.GB12176@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mikep@linuxtr.net, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:43764 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754903AbYBAQS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:18:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Peter's email address is bouncing
- the project webpage no longer exists
- neither Peter nor Mike had a single patch included in the kernel
  since 2.6.12-rc2 (when the git history begins)

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 MAINTAINERS |   23 -----------------------
 1 file changed, 23 deletions(-)

c6ad2e060090ec05fb0cb58f885079360ad48234 
diff --git a/MAINTAINERS b/MAINTAINERS
index ba05e80..f09e844 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -84,13 +84,6 @@ S: Status, one of the following:
 			it has been replaced by a better system and you
 			should be using that.
 
-3C359 NETWORK DRIVER
-P:	Mike Phillips
-M:	mikep@linuxtr.net
-L:	netdev@vger.kernel.org
-W:	http://www.linuxtr.net
-S:	Maintained
-
 3C505 NETWORK DRIVER
 P:	Philip Blundell
 M:	philb@gnu.org
@@ -2864,15 +2857,6 @@ L:	ocfs2-devel@oss.oracle.com
 W:	http://oss.oracle.com/projects/ocfs2/
 S:	Supported
 
-OLYMPIC NETWORK DRIVER
-P:	Peter De Shrijver
-M:	p2@ace.ulyssis.student.kuleuven.ac.be
-P:	Mike Phillips
-M:	mikep@linuxtr.net
-L:	netdev@vger.kernel.org
-W:	http://www.linuxtr.net
-S:	Maintained
-
 OMNIKEY CARDMAN 4000 DRIVER
 P:	Harald Welte
 M:	laforge@gnumonks.org
@@ -3786,13 +3770,6 @@ L:	tlan-devel@lists.sourceforge.net (subscribers-only)
 W:	http://sourceforge.net/projects/tlan/
 S:	Maintained
 
-TOKEN-RING NETWORK DRIVER
-P:	Mike Phillips
-M:	mikep@linuxtr.net
-L:	netdev@vger.kernel.org
-W:	http://www.linuxtr.net
-S:	Maintained
-
 TOSHIBA ACPI EXTRAS DRIVER
 P:	John Belmonte
 M:	toshiba_acpi@memebeam.org

