From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] [IPSEC]: Move xfrm_state_check into xfrm_output.c
Date: Mon, 08 Oct 2007 17:25:29 -0700 (PDT)
Message-ID: <20071008.172529.18732116.davem@davemloft.net>
References: <20071008112818.GA3010@gondor.apana.org.au>
	<E1Ieqnt-0000oB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46280
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752155AbXJIAZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 20:25:30 -0400
In-Reply-To: <E1Ieqnt-0000oB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 08 Oct 2007 19:29:41 +0800

> [IPSEC]: Move xfrm_state_check into xfrm_output.c
> 
> The functions xfrm_state_check and xfrm_state_check_space are only used by
> the output code in xfrm_output.c so we can move them over.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied :)
