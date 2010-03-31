From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 10:24:38 -0400
Message-ID: <1270045478.26743.71.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
	 <20100331132622.GA13908@gondor.apana.org.au>
	 <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi>
	 <20100331135505.GC14082@gondor.apana.org.au>
	 <1270044768.26743.58.camel@bigi>
	 <20100331141525.GA14331@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:14621 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803Ab0CaOYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:24:44 -0400
Received: by ey-out-2122.google.com with SMTP id d26so13185eyd.19
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 07:24:43 -0700 (PDT)
In-Reply-To: <20100331141525.GA14331@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 22:15 +0800, Herbert Xu wrote:

> 
> OK I give up.
> 
> Dave can keep or revert this as he likes.

Ok - I will await to see what Dave thinks before i bother doing whatever
setup. What we have here is a philosophical difference.
Herbert note: i realize this is unfair for me to say given you were
likely very busy: I respect your opinion and knowledge and did CC you on
all the many mails when i was RFCing this and when i sent the patches. 

cheers,
jamal

