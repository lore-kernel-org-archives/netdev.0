From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Kill duplicate xfrm_policy_flush prototype
Date: Tue, 01 Jan 2008 19:08:20 -0800 (PST)
Message-ID: <20080101.190820.237847246.davem@davemloft.net>
References: <20080102030211.GA31886@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752701AbYABDIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 22:08:21 -0500
In-Reply-To: <20080102030211.GA31886@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 2 Jan 2008 14:02:11 +1100

> [IPSEC]: Kill duplicate xfrm_policy_flush prototype
> 
> For five years we had two xfrm_policy_flush prototypes and every time that
> function's signature changed people have been diligently updating both of
> them without noticing :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Quite amazing if you ask me :-)

Patch applied, thanks!
