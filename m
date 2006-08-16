From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][IPSEC]: Aggregate make_jiffies
Date: Wed, 16 Aug 2006 09:13:14 -0400
Message-ID: <1155733994.5122.140.camel@jzny2>
References: <1155693500.5122.39.camel@jzny2>
	 <20060816023349.GA24174@gondor.apana.org.au>
	 <1155697186.5122.43.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:55789 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751175AbWHPNNS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 09:13:18 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GDLCx-0006Ug-AX
	for netdev@vger.kernel.org; Wed, 16 Aug 2006 09:13:19 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1155697186.5122.43.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-15-08 at 22:59 -0400, jamal wrote:

> >  How about moving
> > it to linux/jiffies.h and rewrite in the style of msec_to_jiffies?
> > 
> 
> Is there something other than the boundary check already done you
> foresee being made? If yes, do you wanna take a crack at it?

Herbert, I actually dont know the answer that is why i am punting it to
you;-> I would just move the whole thing to linux/jiffies.h as is but
you seem to suggest there may be other boundary checks. If yes, go at
it ;->

cheers,
jamal




