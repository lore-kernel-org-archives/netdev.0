From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] don't need lmc header file
Date: Sun, 29 Feb 2004 15:05:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229150526.4aa20268.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This file is practically empty and is useless.

--
~Randy


From: Domen Puncer <domen@coderock.org>



 drivers/net/wan/lmc/lmc_proto_raw.h  |    4 ----
 drivers/net/wan/lmc/lmc_proto.c      |    1 -
 2 files changed, 5 deletions(-)

diff -puN drivers/net/wan/lmc/lmc_proto.c~lmc_proto_raw_h_rm drivers/net/wan/lmc/lmc_proto.c
--- linux-263-229/drivers/net/wan/lmc/lmc_proto.c~lmc_proto_raw_h_rm	2004-02-29 13:36:19.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wan/lmc/lmc_proto.c	2004-02-29 13:36:19.000000000 -0800
@@ -50,7 +50,6 @@
 #include "lmc_debug.h"
 #include "lmc_ioctl.h"
 #include "lmc_proto.h"
-//#include "lmc_proto_raw.h"
 
 /*
  * The compile-time variable SPPPSTUP causes the module to be
diff -puN -L drivers/net/wan/lmc/lmc_proto_raw.h drivers/net/wan/lmc/lmc_proto_raw.h~lmc_proto_raw_h_rm /dev/null
--- linux-263-229/drivers/net/wan/lmc/lmc_proto_raw.h
+++ /dev/null	2004-01-21 13:30:42.000000000 -0800
@@ -1,4 +0,0 @@
-#ifndef _LMC_PROTO_RAW_H_
-#define _LMC_PROTO_RAW_H_
-
-#endif

_
