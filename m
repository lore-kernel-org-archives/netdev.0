From: Jon Loeliger <jdl@freescale.com>
Subject: Re: [PATCH 9/10] Add Vitesse 8244 PHY for MPC8641 HPCN platform.
Date: Thu, 08 Jun 2006 15:40:09 -0500
Message-ID: <1149799209.23938.256.camel@cashmere.sps.mot.com>
References: <1149720298.23938.207.camel@cashmere.sps.mot.com>
	 <44887BD3.7000009@garzik.org>
	 <1149797603.23938.251.camel@cashmere.sps.mot.com>
	 <44888A37.3090401@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:35725 "EHLO
	az33egw01.freescale.net") by vger.kernel.org with ESMTP
	id S964997AbWFHUoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 16:44:21 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44888A37.3090401@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-08 at 15:36, Jeff Garzik wrote:
> Is it dependent on other stuff in Paul's tree?

Yes, very much so.  Most of this patch set is an
entirely new PPC board port against his arch/powerpc
basis.  The new PHY is incidentally on that board,
but the patches for its introduction could be
introduced through the netdev tree if needed.
It would just need to be coordinated some.  I am,
of course, willing to work it either way as needed.

jdl


