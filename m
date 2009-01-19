From: David Miller <davem@davemloft.net>
Subject: Re: sfc: Replace LRO with GRO
Date: Mon, 19 Jan 2009 15:27:17 -0800 (PST)
Message-ID: <20090119.152717.147996116.davem@davemloft.net>
References: <1232376006.3004.19.camel@achroite>
	<20090119.132929.108799868.davem@davemloft.net>
	<1232403167.5539.1.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, sfr@canb.auug.org.au
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753247AbZASX1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 18:27:15 -0500
In-Reply-To: <1232403167.5539.1.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 19 Jan 2009 14:12:47 -0800

> On Mon, 2009-01-19 at 13:29 -0800, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > > 
> > > Please could you push this and other GRO changes for .30 to
> > > net-next-2.6?
> > 
> > All of Herbert's bug fixes are going into net-2.6, and that's
> > where they will stay.
> > 
> > I haven't published my net-next-2.6 tree at all, because
> > Stephen Rothwell hasn't stated that such content is
> > OK yet for his -next tree.
> 
> I thought Stephen had stated that anytime _after_ -rc1 was released was
> OK for new material destined for the next release.
> 
> If you're waiting for an explicit OK, I don't think it will forthcoming.

I, unlike some others, value Stephen Rothwell's sanity.  So I will ask
explicitly before potentially spoiling his afternoon :-)
