From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 10/10] pxa: make littleton to use the new smc91x platform data
Date: Mon, 30 Jun 2008 13:24:08 +0100
Message-ID: <20080630122408.GB14862@flint.arm.linux.org.uk>
References: <1214300867-15495-11-git-send-email-eric.y.miao@gmail.com> <4864816F.5070407@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Miao <eric.y.miao@gmail.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Nicolas Pitre <nico@cam.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Eric Miao <eric.miao@marvell.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:45797 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761618AbYF3MYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 08:24:30 -0400
Content-Disposition: inline
In-Reply-To: <4864816F.5070407@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2008 at 01:58:07AM -0400, Jeff Garzik wrote:
> Eric Miao wrote:
> > From: Eric Miao <eric.miao@marvell.com>
> > 
> > Signed-off-by: Eric Miao <eric.miao@marvell.com>
> > ---
> >  arch/arm/mach-pxa/littleton.c |    9 +++++++++
> >  drivers/net/smc91x.h          |    3 ++-
> >  2 files changed, 11 insertions(+), 1 deletions(-)
> 
> The rest of the patches seem OK.
> 
> What do ARM people prefer -- should I ACK this series, and let it be 
> merged via an ARM tree?

I've not seen the patches, so I can't comment.
