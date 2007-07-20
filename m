From: Cal Peake <cp@absolutedigital.net>
Subject: [PATCH] [TRIVIAL] file link fix for Pegasus USB net driver help
Date: Fri, 20 Jul 2007 18:40:52 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707201832160.5706@lancer.cnet.absolutedigital.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: petkan@users.sourceforge.net,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: Trivial Kernel Patches <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from livid.absolutedigital.net ([66.92.46.173]:59711 "EHLO
	mx2.absolutedigital.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758788AbXGTXFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 19:05:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the file link in the Pegasus USB network driver's help text.

Signed-off-by: Cal Peake <cp@absolutedigital.net>

--- ./drivers/net/usb/Kconfig~orig	2007-06-13 18:14:39.000000000 -0400
+++ ./drivers/net/usb/Kconfig	2007-07-20 18:26:57.000000000 -0400
@@ -71,7 +71,7 @@ config USB_PEGASUS
 	select MII
 	---help---
 	  Say Y here if you know you have Pegasus or Pegasus-II based adapter.
-	  If in doubt then look at <file:drivers/usb/net/pegasus.h> for the
+	  If in doubt then look at <file:drivers/net/usb/pegasus.h> for the
 	  complete list of supported devices.
 
 	  If your particular adapter is not in the list and you are _sure_ it
