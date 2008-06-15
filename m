From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 0/9] DM9000 updates for 2.6.27
Date: Mon, 16 Jun 2008 00:26:53 +0100
Message-ID: <20080615232653.642837440@fluff.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54132 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754056AbYFOX2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 19:28:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of updates adds support for the newer DM9000
compatible devices (DM9000A and DM9000B) and support
for faster link-status polling. It also has some source
cleanups and misc fixes.

I've included the DM9000 only part of Laurent's resource
fixes and a few tidyups resulting from these changes.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
