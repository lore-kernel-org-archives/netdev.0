From: Scott Feldman <scott.feldman@intel.com>
Subject: [PATCH 2.6] Update MAINTAINERS with new e100/e1000/ixgb maintainers
Date: Fri, 26 Mar 2004 15:32:16 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403261526120.15875@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: scott.feldman@intel.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com, cramerj@intel.com,
        ayyappan.veeriayan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeff, Adding John/Ganesh/Ayyappan for e100/e100/ixgb in 2.6.  Keeping
myself on for e100 for a couple more 2.6.x releases.

-scott

--------------

--- linux-2.6.4/MAINTAINERS.orig	2004-03-26 10:07:24.000000000 -0800
+++ linux-2.6.4/MAINTAINERS	2004-03-26 10:11:51.000000000 -0800
@@ -1055,23 +1055,33 @@
 S:	Maintained

 INTEL PRO/100 ETHERNET SUPPORT
+P:	John Ronciak
+M:	john.ronciak@intel.com
+P:	Ganesh Venkatesan
+M:	ganesh.venkatesan@intel.com
 P:	Scott Feldman
 M:	scott.feldman@intel.com
+W:	http://sourceforge.net/projects/e1000/
 S:	Supported

 INTEL PRO/1000 GIGABIT ETHERNET SUPPORT
 P:	Jeb Cramer
 M:	cramerj@intel.com
-P:	Scott Feldman
-M:	scott.feldman@intel.com
+P:	John Ronciak
+M:	john.ronciak@intel.com
+P:	Ganesh Venkatesan
+M:	ganesh.venkatesan@intel.com
 W:	http://sourceforge.net/projects/e1000/
 S:	Supported

 INTEL PRO/10GbE SUPPORT
+P:	Ayyappan Veeraiyan
+M:	ayyappan.veeraiyan@intel.com
 P:	Ganesh Venkatesan
-M:	Ganesh.Venkatesan@intel.com
-P:	Scott Feldman
-M:	scott.feldman@intel.com
+M:	ganesh.venkatesan@intel.com
+P:	John Ronciak
+M:	john.ronciak@intel.com
+W:	http://sourceforge.net/projects/e1000/
 S:	Supported

 INTERMEZZO FILE SYSTEM
