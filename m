From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 16/16 2.5] ixgb: white space corrections 2/2
Date: Fri, 15 Oct 2004 06:56:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150645410.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ee.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ee.h	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.h	2004-10-05 15:56:42.000000000 -0700
@@ -34,11 +34,11 @@
 #define IXGB_ETH_LENGTH_OF_ADDRESS   6
 
 /* EEPROM Commands */
-#define EEPROM_READ_OPCODE  0x6	/* EERPOM read opcode */
-#define EEPROM_WRITE_OPCODE 0x5	/* EERPOM write opcode */
-#define EEPROM_ERASE_OPCODE 0x7	/* EERPOM erase opcode */
-#define EEPROM_EWEN_OPCODE  0x13	/* EERPOM erase/write enable */
-#define EEPROM_EWDS_OPCODE  0x10	/* EERPOM erast/write disable */
+#define EEPROM_READ_OPCODE  0x6  /* EERPOM read opcode */
+#define EEPROM_WRITE_OPCODE 0x5  /* EERPOM write opcode */
+#define EEPROM_ERASE_OPCODE 0x7  /* EERPOM erase opcode */
+#define EEPROM_EWEN_OPCODE  0x13 /* EERPOM erase/write enable */
+#define EEPROM_EWDS_OPCODE  0x10 /* EERPOM erase/write disable */
 
 /* EEPROM MAP (Word Offsets) */
 #define EEPROM_IA_1_2_REG        0x0000
