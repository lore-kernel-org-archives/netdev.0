From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Re: ep93xx_eth PHY problems
Date: Sat, 29 Mar 2008 19:17:31 +0100
Message-ID: <20080329181731.GM7701@xi.wantstofly.org>
References: <47CD4857.2060406@student.tuwien.ac.at> <20080321202202.129c1239@ors> <47E9D438.4090206@garzik.org> <20080329191307.665f2056@ors>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org, hvr@gnu.org
To: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:41934 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbYC2SRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 14:17:33 -0400
Content-Disposition: inline
In-Reply-To: <20080329191307.665f2056@ors>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2008 at 07:13:07PM +0100, Oliver Martin wrote:

> > ACKs from Lennert, others?
> > 
> > I don't know enough about the hardware to say...
> > 
> > Seems straightforward to me?
> > 
> > 2.6.25 or 2.6.26 material?
> 
> It depends on Herbert Valerio Riedel's ep93xx_eth phylib conversion,
> which isn't in 2.6.25-rc7 (but received an ACK from Lennert some
> weeks ago). I guess it should go in whenever that is merged.

ACK for 2.6.26, together with Herbert's changes.

Herbert, can you resend your latest?
