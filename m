From: Neil Horman <nhorman@redhat.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Fri, 21 May 2010 08:59:53 -0400
Message-ID: <20100521125953.GB29817@hmsreliant.think-freely.org>
References: <20100520172918.GA17613@shamino.rdu.redhat.com>
 <20100520231630.GA22593@gondor.apana.org.au>
 <20100521003939.GA2223@localhost.localdomain>
 <20100520.224944.102694876.davem@davemloft.net>
 <20100521105128.GA29521@hmsreliant.think-freely.org>
 <20100521110847.GA29878@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223Ab0EUNAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 09:00:14 -0400
Content-Disposition: inline
In-Reply-To: <20100521110847.GA29878@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 21, 2010 at 09:08:47PM +1000, Herbert Xu wrote:
> On Fri, May 21, 2010 at 06:51:28AM -0400, Neil Horman wrote:
> >
> > I read it, we just described the issue in diferent terms.
> 
> Yeah I wasn't clear enough with my email without an actual patch :)
> 
No worries, its not an easy issue to describe :)

> Thanks for testing Neil!
Thanks for the patch, I'll let you know how it works out in just a bit here!
Neil

> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
