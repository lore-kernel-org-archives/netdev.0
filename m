From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 8/16 2.5] ixgb: remove sub-device ids for non-existant hardware
Date: Fri, 15 Oct 2004 06:55:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150632560.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ids.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_ids.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ids.h	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ids.h	2004-10-05 17:54:44.000000000 -0700
@@ -42,11 +42,7 @@
 #define IXGB_SUBDEVICE_ID_A11F  0xA11F
 #define IXGB_SUBDEVICE_ID_A01F  0xA01F
 
-#define IXGB_SUBDEVICE_ID_A15F  0xA15F
-#define IXGB_SUBDEVICE_ID_A05F  0xA05F
 
-#define IXGB_SUBDEVICE_ID_A12F  0xA12F
-#define IXGB_SUBDEVICE_ID_A02F  0xA02F
 
 #endif				/* #ifndef _IXGB_IDS_H_ */
 
