From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 4/10] ixgb: Remove sub-device ids for non-existant
 hardware
Date: Fri, 29 Oct 2004 05:09:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290448590.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb_ids.h netdev-2.6/drivers/net/ixgb.new/ixgb_ids.h
--- netdev-2.6/drivers/net/ixgb/ixgb_ids.h	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_ids.h	2004-10-15 13:15:54.000000000 -0700
@@ -42,11 +42,7 @@
 #define IXGB_SUBDEVICE_ID_A11F  0xA11F
 #define IXGB_SUBDEVICE_ID_A01F  0xA01F
 
-#define IXGB_SUBDEVICE_ID_A15F  0xA15F
-#define IXGB_SUBDEVICE_ID_A05F  0xA05F
 
-#define IXGB_SUBDEVICE_ID_A12F  0xA12F
-#define IXGB_SUBDEVICE_ID_A02F  0xA02F
 
 #endif				/* #ifndef _IXGB_IDS_H_ */
 
