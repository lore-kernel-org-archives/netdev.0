From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 5/5 2.5] e1000: white space corrections
Date: Fri, 15 Oct 2004 06:52:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150545520.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up netdev-2.6/drivers/net/e1000/e1000_ethtool.c netdev-2.6/drivers/net/e1000.new/e1000_ethtool.c
--- netdev-2.6/drivers/net/e1000/e1000_ethtool.c	2004-10-07 13:59:52.000000000 -0700
+++ netdev-2.6/drivers/net/e1000.new/e1000_ethtool.c	2004-10-07 13:59:53.000000000 -0700
@@ -641,7 +641,6 @@ err_setup_rx:
 	return err;
 }
 
-
 #define REG_PATTERN_TEST(R, M, W)                                              \
 {                                                                              \
 	uint32_t pat, value;                                                   \
