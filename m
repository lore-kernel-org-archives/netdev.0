From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch] (revised) net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Sat, 3 May 2008 23:06:06 +0800
Message-ID: <20080503150606.GA26898@gondor.apana.org.au>
References: <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain> <20080501011123.GA4060@gondor.apana.org.au> <alpine.LFD.1.10.0805021323470.3349@localhost.localdomain> <20080502.165455.24687234.davem@davemloft.net> <20080503144647.GF3986@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	akpm@osdl.org, netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54240 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755709AbYECPGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 11:06:15 -0400
Content-Disposition: inline
In-Reply-To: <20080503144647.GF3986@hack>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 03, 2008 at 10:46:49PM +0800, WANG Cong wrote:
> 
> I will try if I can set up one, then test it.

I'll throw them into my test systems here and see if they break.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
