From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 0/6] Misc driver fixes for 2.6.32
Date: Thu, 05 Nov 2009 16:25:55 +0100
Message-ID: <20091105152555.227009519@linux-mips.org>
Cc: David Daney <ddaney@caviumnetworks.com>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	Julia Lawall <julia@diku.dk>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	devel@driverdev.osuosl.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	spi-devel-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:45221 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757851AbZKERzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 12:55:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of patches which 

  o 1/6, 2/6, 3/6: Fixes for the Octeon ethernet driver in drivers/staging.
    The Octeon is a MIPS-based SOC so with permisson from Greg I'm merging
    these via the MIPS tree.
  o 4/6: A fix to a MIPS-specific SPI driver.  Posted before, no comments
    were received.
  o 5/6: A fix to the resource allocation to the framebuffer of the MIPS-
    based SGI O2 and i686-based Visual Workstation.  Also posted before, no
    comments were received.
  o 6/6: A fix to the serial driver for the BCM63xx which is a MIPS-based
    SOC.

  Ralf

