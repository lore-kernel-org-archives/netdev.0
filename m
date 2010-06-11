From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Fri, 11 Jun 2010 12:11:42 +1000
Message-ID: <20100611021142.GA24490@gondor.apana.org.au>
References: <20100610124047.GA16658@gondor.apana.org.au> <20100610074912.1303e3da@nehalam> <20100610215643.GA22048@gondor.apana.org.au> <20100610145915.721a86b7@nehalam> <20100610224839.GA22469@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>, Matt Mackall <mpm@selenic.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:38000 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760075Ab0FKCLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 22:11:50 -0400
Content-Disposition: inline
In-Reply-To: <20100610224839.GA22469@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
> On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrote:
> >
> > Okay, then add a comment where in_irq is used?
> 
> Actually let me put it into a wrapper.  I'll respin the patches.

OK here is a repost.  And this time it really is 8 patches :)
I've tested it lightly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
