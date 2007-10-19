From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/8] [MV643XX_ETH] Move ethernet register definitions into private header
Date: Fri, 19 Oct 2007 16:00:15 +0200
Message-ID: <20071019140015.GM16037@xi.wantstofly.org>
References: <20071019021010.GD16037@xi.wantstofly.org> <20071019083048.GA16865@infradead.org> <20071019110957.GL16037@xi.wantstofly.org> <20071019125654.GA11495@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:35372 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753960AbXJSOAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 10:00:17 -0400
Content-Disposition: inline
In-Reply-To: <20071019125654.GA11495@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 05:56:54AM -0700, Dale Farnsworth wrote:

> > > Isn't it a little too confusing to have two headers with the same name,
> > > one in drivers/net and one in include/linux?
> > 
> > Perhaps we can fold the drivers/net one into drivers/net/mv643xx_eth.c?
> > Since nothing else includes drivers/net/mv643xx_eth.h anyway, there's
> > not much point in having it separate.
> 
> Sounds good to me.  Please add a patch to do so.

Okay.
