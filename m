From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 9/9] sky2: version 1.3
Date: Mon, 08 May 2006 15:11:34 -0700
Message-ID: <20060508221229.817426000@localhost.localdomain>
References: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15549 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751334AbWEHWX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:59 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNntH003761
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:50 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNnRU023574
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:49 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=sky2-1.4.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update version number, to track changes.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -51,7 +51,7 @@
 #include "sky2.h"
 
 #define DRV_NAME		"sky2"
-#define DRV_VERSION		"1.2"
+#define DRV_VERSION		"1.3"
 #define PFX			DRV_NAME " "
 
 /*

--

