From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 4/5 2.5] e1000: driver version update
Date: Fri, 15 Oct 2004 06:52:44 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150544270.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.new/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-10-07 13:59:52.000000000 -0700
+++ netdev-2.6/drivers/net/e1000.new/e1000_main.c	2004-10-07 13:59:54.000000000 -0700
@@ -48,7 +48,7 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.3.19-k2"DRIVERNAPI;
+char e1000_driver_version[] = "5.5.4-k2"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
