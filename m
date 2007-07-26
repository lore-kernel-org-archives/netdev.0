From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/6] Allow registration/change name notifications to fail
Date: Thu, 26 Jul 2007 19:03:14 +0800
Message-ID: <20070726110314.GA1447@gondor.apana.org.au>
References: <20070726090725.GA510@gondor.apana.org.au> <20070726113715.6a4b5af9@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1736 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757322AbXGZLDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 07:03:20 -0400
Content-Disposition: inline
In-Reply-To: <20070726113715.6a4b5af9@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 26, 2007 at 11:37:15AM +0100, Stephen Hemminger wrote:
>
> Thanks for looking at this, are there bugs this fixes so it should
> go to stable?

Well it does fix bugs but I'm a bit anxious about pushing it
to stable straight away because the likelihood of it breaking
something else is just as great.

Perhaps once it's been tested a while then we could push it back.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
