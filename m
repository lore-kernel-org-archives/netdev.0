From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller
	(try #7)
Date: Mon, 03 Mar 2008 14:22:55 -0500
Message-ID: <1204572175.16248.5.camel@localhost.localdomain>
References: <20080303185624.GC2988@solarflare.com>
	 <20080303.110206.36977456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52398 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbYCCT0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 14:26:03 -0500
In-Reply-To: <20080303.110206.36977456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-03-03 at 11:02 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 3 Mar 2008 18:56:24 +0000
> 
> > The patch (against netdev-2.6) is at:
> >   https://support.solarflare.com/netdev/7/netdev-2.6-sfc-2.2.0106.patch
> 
> Nobody can properly review the driver if it's off on some external web
> site instead of posted here.

The diff is 707K; I certainly thought that netdev had a message size
limit.  What's the proper policy on splitting up _new_ drivers?  There
may/may not be a good way of splitting up any given new driver for
piecemeal in-line review.  If there's not, what's the alternative?

Dan


