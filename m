From: Brice Goglin <brice@myri.com>
Subject: [PATCH][MAINTAINERS] Add maintainers for myri10ge driver
Date: Tue, 13 May 2008 20:36:06 +0200
Message-ID: <4829DF96.7080208@myri.com>
References: <482397A3.1050604@myri.com> <482398F6.3060902@myri.com> <48292B82.5090304@garzik.org> <4829DF53.3080600@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1801 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753100AbYEMSgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 14:36:13 -0400
In-Reply-To: <4829DF53.3080600@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a MAINTAINERS entry for the myri10ge driver.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 MAINTAINERS |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux-2.6.git/MAINTAINERS
===================================================================
--- linux-2.6.git.orig/MAINTAINERS	2008-05-13 20:29:45.000000000 +0200
+++ linux-2.6.git/MAINTAINERS	2008-05-13 20:30:32.000000000 +0200
@@ -2808,6 +2808,15 @@
 L:	linux-kernel@vger.kernel.org
 S:	Maintained
 
+MYRICOM MYRI-10G 10GbE DRIVER (MYRI10GE)
+P:	Andrew Gallatin
+M:	gallatin@myri.com
+P:	Brice Goglin
+M:	brice@myri.com
+L:	netdev@vger.kernel.org
+W:	http://www.myri.com/scs/download-Myri10GE.html
+S:	Supported
+
 NATSEMI ETHERNET DRIVER (DP8381x)
 P: 	Tim Hockin
 M:	thockin@hockin.org


