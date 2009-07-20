From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 1/3] can: sja1000: remove duplicated includes
Date: Mon, 20 Jul 2009 16:06:39 +0200
Message-ID: <20090720140638.584090253@denx.de>
References: <20090720140638.342067093@denx.de>
Cc: socketcan-core@lists.berlios.de,
	Huang Weiyi <weiyi.huang@gmail.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:39561 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715AbZGTOGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:06:40 -0400
Content-Disposition: inline; filename=sja1000-remove-duplicate-includes.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  drivers/net/can/sja1000/sja1000.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/sja1000/sja1000.c |    1 -
 1 file changed, 1 deletion(-)

Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c	2009-07-20 15:04:52.150997074 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c	2009-07-20 15:33:22.289997606 +0200
@@ -63,7 +63,6 @@
 #include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
-#include <linux/can/dev.h>
 
 #include "sja1000.h"
 

