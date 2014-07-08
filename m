From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH C 0/7] Freescale ethernet driver updates (part 3)
Date: Tue, 8 Jul 2014 13:01:17 +0100
Message-ID: <20140708120117.GJ21766@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58728 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754499AbaGHMBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 08:01:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Here's the third batch of patches for the Freescale FEC ethernet driver,
based upon the previous set of patches.  This concludes the changes I
currently have prepared and have been reviewed for the next merge window
at this time.

Many thanks.

 drivers/net/ethernet/freescale/fec.h      |   9 +-
 drivers/net/ethernet/freescale/fec_main.c | 139 ++++++++++++++----------------
 2 files changed, 68 insertions(+), 80 deletions(-)

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
