From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 9/10] Add Vitesse 8244 PHY for MPC8641 HPCN platform.
Date: Thu, 08 Jun 2006 16:46:43 -0400
Message-ID: <44888CB3.1060507@garzik.org>
References: <1149720298.23938.207.camel@cashmere.sps.mot.com>	 <44887BD3.7000009@garzik.org>	 <1149797603.23938.251.camel@cashmere.sps.mot.com>	 <44888A37.3090401@garzik.org> <1149799209.23938.256.camel@cashmere.sps.mot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:23257 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964998AbWFHUqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 16:46:47 -0400
To: Jon Loeliger <jdl@freescale.com>
In-Reply-To: <1149799209.23938.256.camel@cashmere.sps.mot.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Loeliger wrote:
> On Thu, 2006-06-08 at 15:36, Jeff Garzik wrote:
>> Is it dependent on other stuff in Paul's tree?
> 
> Yes, very much so.  Most of this patch set is an
> entirely new PPC board port against his arch/powerpc
> basis.  The new PHY is incidentally on that board,
> but the patches for its introduction could be
> introduced through the netdev tree if needed.
> It would just need to be coordinated some.  I am,
> of course, willing to work it either way as needed.

I leave it up to you and Paul to coordinate, then :)

I'm fine with the patch, and if its better to merge via linuxppc.git, 
that's OK with me.  If you would prefer to send it via my tree, to go 
ahead and get it in, that's fine too.

	Jeff



