From: Jason Uhlenkott <jasonuhl@jasonuhl.org>
Subject: [PATCH] e1000e Kconfig: remove ref to nonexistant docs
Date: Wed, 16 Jan 2008 23:03:17 -0800
Message-ID: <20080117070317.GA7922@aurum.uhlenkott.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-117-79-109.dsl.sntc01.pacbell.net ([67.117.79.109]:1871
	"EHLO aurum.uhlenkott.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbYAQHI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 02:08:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no Documentation/networking/e1000e.txt.

Signed-off-by: Jason Uhlenkott <jasonuhl@jasonuhl.org>
Cc: Auke Kok <auke-jan.h.kok@intel.com>
---

Index: linux/drivers/net/Kconfig
===================================================================
--- linux.orig/drivers/net/Kconfig	2008-01-16 17:48:03.041103083 -0800
+++ linux/drivers/net/Kconfig	2008-01-16 23:00:23.647430487 -0800
@@ -1976,9 +1976,6 @@
 
 	  <http://support.intel.com>
 
-	  More specific information on configuring the driver is in
-	  <file:Documentation/networking/e1000e.txt>.
-
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
 
