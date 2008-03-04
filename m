From: David Miller <davem@davemloft.net>
Subject: Re: [ESP]: Add select on AUTHENC
Date: Tue, 04 Mar 2008 14:29:34 -0800 (PST)
Message-ID: <20080304.142934.76573252.davem@davemloft.net>
References: <20080304121752.GA17343@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kazunori@miyazawa.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755885AbYCDW3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:29:41 -0500
In-Reply-To: <20080304121752.GA17343@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 4 Mar 2008 20:17:52 +0800

> This patch should make the IPv6 tests work again.
> 
> [ESP]: Add select on AUTHENC
> 
> Now the ESP uses the AEAD interface even for algorithms which are
> not combined mode, we need to select CONFIG_CRYPTO_AUTHENC as
> otherwise only combined mode algorithms will work.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot!
