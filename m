From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: What is XFRM_POLICY_LOCALOK for?
Date: Sat, 12 Jan 2008 22:16:47 +1100
Message-ID: <E1JDeM3-00016d-00@gondolin.me.apana.org.au>
References: <d0383f90801120031r142b2be1taee5efd190768407@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: ianbrn@gmail.com (Ian Brown)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2696 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761753AbYALLQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 06:16:51 -0500
In-Reply-To: <d0383f90801120031r142b2be1taee5efd190768407@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Brown <ianbrn@gmail.com> wrote:
> 
> I tried to understand what XFRM_POLICY_LOCALOK is for. (include/linux/xfrm.h)
> It is defined thus:
> #define XFRM_POLICY_LOCALOK    1       /* Allow user to override global policy */

It isn't used anywhere.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
