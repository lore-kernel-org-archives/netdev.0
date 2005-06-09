From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Re: netdev munching messages again?
Date: Thu, 9 Jun 2005 17:18:32 +0100
Message-ID: <20050609161832.GJ4927@linux-mips.org>
References: <20050608161314.GM20969@postel.suug.ch> <20050608172809.GF5520@linux-mips.org> <20050608200048.GP20969@postel.suug.ch> <20050608.131044.31642070.davem@davemloft.net> <20050609132730.GF4927@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, hadi@cyberus.ca, netdev@oss.sgi.com,
        Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050609132730.GF4927@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change the address of netdev in 2.4 also.

 Documentation/networking/vortex.txt |    2 +-
 MAINTAINERS                         |   10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

Index: linux-cvs-2.4/Documentation/networking/vortex.txt
===================================================================
--- linux-cvs-2.4.orig/Documentation/networking/vortex.txt	2002-06-26 23:35:01.000000000 +0100
+++ linux-cvs-2.4/Documentation/networking/vortex.txt	2005-06-09 14:53:43.000000000 +0100
@@ -12,7 +12,7 @@
 Please report problems to one or more of:
 
   Andrew Morton <andrewm@uow.edu.au>
-  Netdev mailing list <netdev@oss.sgi.com>
+  Netdev mailing list <netdev@vger.kernel.org>
   Linux kernel mailing list <linux-kernel@vger.kernel.org>
 
 Please note the 'Reporting and Diagnosing Problems' section at the end
Index: linux-cvs-2.4/MAINTAINERS
===================================================================
--- linux-cvs-2.4.orig/MAINTAINERS	2005-05-05 10:36:01.000000000 +0100
+++ linux-cvs-2.4/MAINTAINERS	2005-06-09 14:53:43.000000000 +0100
@@ -116,7 +116,7 @@
 8169 10/100/1000 GIGABIT ETHERNET DRIVER
 P:	Francois Romieu
 M:	romieu@fr.zoreil.com
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
 
 8250/16?50 (AND CLONE UARTS) SERIAL DRIVER
@@ -1186,7 +1186,7 @@
 P:	Manish Lachwani
 M:	Manish_Lachwani@pmc-sierra.com
 L:	linux-mips@linux-mips.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Supported
 
 MARVELL YUKON / SYSKONNECT DRIVER
@@ -1315,7 +1315,7 @@
 
 NETWORKING [GENERAL]
 P:	Networking Team
-M:	netdev@oss.sgi.com
+M:	netdev@vger.kernel.org
 L:	linux-net@vger.kernel.org
 S:	Maintained
 
@@ -1332,7 +1332,7 @@
 M:	yoshfuji@linux-ipv6.org
 P:	Patrick McHardy
 M:	kaber@coreworks.de
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 S:	Maintained
 
 NFS CLIENT
@@ -1529,7 +1529,7 @@
 PRISM54 WIRELESS DRIVER
 P:	Prism54 Development Team
 M:	prism54-private@prism54.org
-L:	netdev@oss.sgi.com
+L:	netdev@vger.kernel.org
 W:	http://prism54.org
 S:	Maintained
 
