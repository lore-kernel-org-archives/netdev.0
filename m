From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Sun, 3 Aug 2008 10:01:04 +0800
Message-ID: <20080803020104.GA32076@gondor.apana.org.au>
References: <48929C5B.5030108@cn.fujitsu.com> <E1KOqf7-0004lB-00@gondolin.me.apana.org.au> <20080801.021825.51896743.davem@davemloft.net> <20080801092548.GA18424@gondor.apana.org.au> <20080801115041.GA19124@gondor.apana.org.au> <20080801131453.GA19851@gondor.apana.org.au> <489322A9.3080906@hp.com> <20080802003016.GA24295@gondor.apana.org.au> <4894ED25.6040200@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60858 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750935AbYHCCB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2008 22:01:28 -0400
Content-Disposition: inline
In-Reply-To: <4894ED25.6040200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 02, 2008 at 07:26:29PM -0400, Vlad Yasevich wrote:
>
> OK, I see what you mean.  Let me run some tests with this patch.  I doesn't
> look like it will cause any issues, but I'd like to verify.

Thanks Vlad!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
