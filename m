From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH B 00/10] Freescale ethernet driver updates (part 2)
Date: Tue, 8 Jul 2014 12:39:11 +0100
Message-ID: <20140708113911.GH21766@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58510 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753906AbaGHLjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 07:39:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here's the second batch of patches for the Freescale FEC ethernet driver,
based upon the previous set of patches.  One further set of 7 patches
remains.

Many thanks.

 drivers/net/ethernet/freescale/fec_main.c | 127 ++++++++++++++++++++----------
 1 file changed, 84 insertions(+), 43 deletions(-)
