From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 5/5 2.4] e1000: white space corrections
Date: Fri, 15 Oct 2004 06:51:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150534590.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_param.c linux-2.4/drivers/net/e1000.new/e1000_param.c
--- linux-2.4/drivers/net/e1000/e1000_param.c	2004-10-07 09:11:14.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_param.c	2004-10-07 09:11:17.000000000 -0700
@@ -211,7 +211,7 @@ E1000_PARAM(InterruptThrottleRate, "Inte
 #define MAX_TXABSDELAY            0xFFFF
 #define MIN_TXABSDELAY                 0
 
-#define DEFAULT_ITR                 8000 
+#define DEFAULT_ITR                 8000
 #define MAX_ITR                   100000
 #define MIN_ITR                      100
 
Only in linux-2.4/drivers/net/e1000.new: kcompat_ethtool.c
