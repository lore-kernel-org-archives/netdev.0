From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 22:29:15 +0800
Message-ID: <20100331142915.GA14557@gondor.apana.org.au>
References: <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi> <20100331131131.GA13793@gondor.apana.org.au> <20100331132622.GA13908@gondor.apana.org.au> <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi> <20100331135505.GC14082@gondor.apana.org.au> <1270044768.26743.58.camel@bigi> <20100331141525.GA14331@gondor.apana.org.au> <1270045478.26743.71.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:51414 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751770Ab0CaO3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:29:33 -0400
Content-Disposition: inline
In-Reply-To: <1270045478.26743.71.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 10:24:38AM -0400, jamal wrote:
> On Wed, 2010-03-31 at 22:15 +0800, Herbert Xu wrote:
> 
> > 
> > OK I give up.
> > 
> > Dave can keep or revert this as he likes.
> 
> Ok - I will await to see what Dave thinks before i bother doing whatever
> setup. What we have here is a philosophical difference.
> Herbert note: i realize this is unfair for me to say given you were
> likely very busy: I respect your opinion and knowledge and did CC you on
> all the many mails when i was RFCing this and when i sent the patches. 

Yes you did cc me.  Unfortunately I was rather busy with some other
stuff at the time.  Had I read your patch back then I would've said
something :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
