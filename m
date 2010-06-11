From: Matt Mackall <mpm@selenic.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Fri, 11 Jun 2010 15:03:19 -0500
Message-ID: <1276286599.1178.698.camel@calx>
References: <20100610124047.GA16658@gondor.apana.org.au>
	 <20100610074912.1303e3da@nehalam>
	 <20100610215643.GA22048@gondor.apana.org.au>
	 <20100610145915.721a86b7@nehalam>
	 <20100610224839.GA22469@gondor.apana.org.au>
	 <20100611021142.GA24490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:47999 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038Ab0FKUDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 16:03:23 -0400
In-Reply-To: <20100611021142.GA24490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-11 at 12:11 +1000, Herbert Xu wrote:
> On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
> > On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrote:
> > >
> > > Okay, then add a comment where in_irq is used?
> > 
> > Actually let me put it into a wrapper.  I'll respin the patches.
> 
> OK here is a repost.  And this time it really is 8 patches :)
> I've tested it lightly.

These all look very nice to me, thanks for digging into this. 

Acked-by: Matt Mackall <mpm@selenic.com>

Hopefully we'll also get an ack from Wang Cong on them and another test
result.

-- 
Mathematics is the supreme nostalgia of our time.


