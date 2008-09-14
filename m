From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 0/2] drivers/net/bonding sparse errors
Date: Sun, 14 Sep 2008 16:56:11 +0100
Message-ID: <20080914155611.272940975@fluff.org.uk>
To: Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:61049 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753131AbYINP5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 11:57:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/bonding throws a large number of warnings
when compiling a kernel with sparse. These two patches
remove the easiest offenders to try and cut down the
number and see what is important.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
