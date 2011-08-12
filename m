From: Robin Holt <holt@sgi.com>
Subject: [PATCH v12 0/6] flexcan/powerpc: Add support for powerpc flexcan (freescale p1010)
Date: Fri, 12 Aug 2011 03:45:46 -0500
Message-ID: <1313138752-24006-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>, Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:39012 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752421Ab1HLIqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 04:46:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With all the patches applied, my p1010rdb works for communicating between
its two can ports and also can communicate with an external PSOC.
I have done no testing beyond compile testing for an arm system as I
have no access to an arm based system.

With the latest version, changes to the arch tree really only reflect
changes in the drivers/net/can tree.  I, therefore, believe it is
probably best to route them through David S. Miller's netdev tree.
Wolfgang and Kumar, does that seem correct to you?

Thanks,
Robin Holt
