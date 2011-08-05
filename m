From: Robin Holt <holt@sgi.com>
Subject: [RFC 0/4] [flexcan] Add support for powerpc (freescale p1010) -V4
Date: Thu,  4 Aug 2011 21:06:15 -0500
Message-ID: <1312509979-13226-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:57777 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877Ab1HECGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 22:06:22 -0400
To: Robin Holt <holt@sgi.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc or Wolfgang,

This patch set should have all your comments included.

Could you please apply these four patches to a test branch, compile
and test them on an arm based system?  I would like to at least feel
comfortable that I have not broken anything there so far.

Before the integration of the comments, I had verified the flexcan
driver was able to communicate.  I still need to do more testing, but
it certainly looks very promising at this point.

Thanks,
Robin Holt
