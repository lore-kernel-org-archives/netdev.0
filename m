From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Fri, 20 Mar 2015 19:55:09 +1100
Message-ID: <20150320085509.GA16748@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
 <20150316111345.GA22070@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:45541 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbbCTIzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 04:55:22 -0400
Content-Disposition: inline
In-Reply-To: <20150316111345.GA22070@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 11:13:46AM +0000, Patrick McHardy wrote:
>
> An upcoming patchset will add transaction support to sets, which needs
> the callback. So please leave it for know since it will only cause
> unnecessary churn.

Patrick, can you explain what you mean by the callback?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
