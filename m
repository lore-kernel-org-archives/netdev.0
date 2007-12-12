From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [IPSEC]: Added xfrm_decode_session_reverse and
 xfrmX_policy_check_reverse
Date: Wed, 12 Dec 2007 10:44:25 -0800 (PST)
Message-ID: <20071212.104425.223366052.davem@davemloft.net>
References: <20071212012552.GA20618@gondor.apana.org.au>
	<E1J2GrI-0005SX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbXLLSoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:44:25 -0500
In-Reply-To: <E1J2GrI-0005SX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Dec 2007 09:58:00 +0800

> [IPSEC]: Added xfrm_decode_session_reverse and xfrmX_policy_check_reverse
> 
> RFC 4301 requires us to relookup ICMP traffic that does not match any
> policies using the reverse of its payload.  This patch adds the functions
> xfrm_decode_session_reverse and xfrmX_policy_check_reverse so we can get
> the reverse flow to perform such a lookup.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
