From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 10:38:10 -0400
Message-ID: <1270046290.26743.76.camel@bigi>
References: <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
	 <20100331132622.GA13908@gondor.apana.org.au>
	 <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi>
	 <20100331135505.GC14082@gondor.apana.org.au>
	 <1270044768.26743.58.camel@bigi>
	 <20100331141525.GA14331@gondor.apana.org.au>
	 <1270045478.26743.71.camel@bigi>
	 <20100331142915.GA14557@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:63397 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab0CaOiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:38:19 -0400
Received: by ewy20 with SMTP id 20so53174ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 07:38:17 -0700 (PDT)
In-Reply-To: <20100331142915.GA14557@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 22:29 +0800, Herbert Xu wrote:

> Yes you did cc me.  Unfortunately I was rather busy with some other
> stuff at the time.  Had I read your patch back then I would've said
> something :)

makes sense ;-> And it wouldnt have been like the first (or the last)
time you and i have had this heated discussions;->
Lets just wait to hear what Dave says - I dont want make his life more
difficult than it is; so no hard feeling if he decides to revert.


cheers,
jamal

PS:- since you woke me up and i know you are awake, 
i am going to get rid of a jetlag by sending
probably another controversial patch. Hmmm.. where to start.

