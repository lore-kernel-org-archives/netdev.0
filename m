From: Scott Feldman <scott.feldman@intel.com>
Subject: [PATCH 2.4] Update MAINTAINERS with new e100/e100 maintainers
Date: Fri, 26 Mar 2004 15:26:09 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403261519010.15875@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: scott.feldman@intel.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com, cramerj@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff, removing myself and adding John/Ganesh as new maintainers for
e100/e1000 in 2.4.

-scott

-----------

--- linux-2.4.25/MAINTAINERS.orig	2004-03-26 10:07:45.000000000 -0800
+++ linux-2.4.25/MAINTAINERS	2004-03-26 10:08:35.000000000 -0800
@@ -954,14 +954,24 @@
 M:	tigran@veritas.com
 S:	Maintained

+INTEL PRO/100 ETHERNET SUPPORT
+P:	John Ronciak
+M:	john.ronciak@intel.com
+P:	Ganesh Venkatesan
+M:	Ganesh.Venkatesan@intel.com
+W:	http://sourceforge.net/projects/e1000/
+S:	Supported
+
 INTEL PRO/1000 GIGABIT ETHERNET SUPPORT
 P:	Jeb Cramer
 M:	cramerj@intel.com
-P:	Scott Feldman
-M:	scott.feldman@intel.com
+P:	John Ronciak
+M:	john.ronciak@intel.com
+P:	Ganesh Venkatesan
+M:	Ganesh.Venkatesan@intel.com
 W:	http://sourceforge.net/projects/e1000/
 S:	Supported
-
+
 INTERMEZZO FILE SYSTEM
 P:	Chen Yang
 M:	intermezzo-devel@lists.sourceforge.net
