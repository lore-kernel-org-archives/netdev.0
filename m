From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/4] GRO optimisations
Date: Fri, 30 Jan 2009 12:29:42 +1100
Message-ID: <20090130012942.GA1968@gondor.apana.org.au>
References: <20090130001849.GA1272@gondor.apana.org.au> <498249C9.3050708@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54739 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755624AbZA3B3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:29:49 -0500
Content-Disposition: inline
In-Reply-To: <498249C9.3050708@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2009 at 04:28:57PM -0800, Divy Le Ray wrote:
>
> I'll give these patches a try within a day or two.

It should be the same as the kernel that you did the last test
on, i.e., the one that was giving 5.7Gb/s but please reconfirm
that I haven't screwed it up in merging.

> Please note that the 6Gb/s rate is achieved on a low perf server.
> Using this server makes it easy to witness the impact of optimizations.
> Faster boxes reach line rate.
> Just want to make clear that cxgb3 HW is not limited to 6Gb/s ;)

Of course, any inferences that it was limited wasn't intentional :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
