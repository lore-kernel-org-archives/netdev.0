From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 0/7][MV643XX_ETH] various cleanups
Date: Tue, 18 Mar 2008 15:03:53 -0700
Message-ID: <20080318220353.GA9479@farnsworth.org>
References: <20080317191546.GA17828@xi.wantstofly.org> <20080318161406.GA27913@farnsworth.org> <20080318164045.GB28917@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:50149 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbYCTGHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 02:07:43 -0400
Content-Disposition: inline
In-Reply-To: <20080318164045.GB28917@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2008 at 05:40:45PM +0100, Lennert Buytenhek wrote:
> On Tue, Mar 18, 2008 at 09:14:06AM -0700, Dale Farnsworth wrote:
> > I'm happy with the end result, but the current patch series will
> > not build after patches 1-3 are applied.  Please reorder your
> > code changes so the result will be git-bisectable.
> 
> Urgh.  I could have sworn that I checked that.  Anyway, sorry.
> 
> Fixed patch series here:
> 	http://www.wantstofly.org/~buytenh/mv643xx_eth/

Yes.  :)

I've applied all 1-7 of these to the for-2.6.26 branch of
	git://git.farnsworth.org/dale/linux-2.6-mv643xx_eth.git for-2.6.26

It's also viewable at
<http://www.farnsworth.org/git?p=dale/linux-2.6-mv643xx_eth.git;a=shortlog;h=for-2.6.26>

-Dale
