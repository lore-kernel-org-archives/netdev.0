From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [IPSEC]: Move RO-specific output code into
 xfrm6_mode_ro.c
Date: Mon, 08 Oct 2007 17:27:37 -0700 (PDT)
Message-ID: <20071008.172737.82720791.davem@davemloft.net>
References: <20071008112818.GA3010@gondor.apana.org.au>
	<E1Ieqnw-0000oO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46292
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752318AbXJIA1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 20:27:38 -0400
In-Reply-To: <E1Ieqnw-0000oO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 08 Oct 2007 19:29:44 +0800

> [IPSEC]: Move RO-specific output code into xfrm6_mode_ro.c
> 
> The lastused update check in xfrm_output can be done just as well in
> the mode output function which is specific to RO.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert!
