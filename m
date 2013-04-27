From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/6] vxlan: update mail address and copyright date
Date: Sat, 27 Apr 2013 14:31:52 -0700
Message-ID: <20130427213258.131394050@vyatta.com>
References: <20130427213151.255971631@vyatta.com>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52173 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986Ab3D0Vqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 17:46:36 -0400
Content-Disposition: inline; filename=vxlan-fix-mail.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2013-04-27 13:36:18.118396437 -0700
+++ b/drivers/net/vxlan.c	2013-04-27 13:38:54.124378801 -0700
@@ -1,7 +1,7 @@
 /*
  * VXLAN: Virtual eXtensible Local Area Network
  *
- * Copyright (c) 2012 Vyatta Inc.
+ * Copyright (c) 2012-2013 Vyatta Inc.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -1663,5 +1663,5 @@ module_exit(vxlan_cleanup_module);
 
 MODULE_LICENSE("GPL");
 MODULE_VERSION(VXLAN_VERSION);
-MODULE_AUTHOR("Stephen Hemminger <shemminger@vyatta.com>");
+MODULE_AUTHOR("Stephen Hemminger <stephen@networkplumber.org>");
 MODULE_ALIAS_RTNL_LINK("vxlan");
