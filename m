From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Move all calls to xfrm_audit_state_icvfail to
 xfrm_input
Date: Sun, 30 Dec 2007 21:11:13 -0800 (PST)
Message-ID: <20071230.211113.147623948.davem@davemloft.net>
References: <20071231042355.GA9215@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48910
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751407AbXLaFLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 00:11:14 -0500
In-Reply-To: <20071231042355.GA9215@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 31 Dec 2007 15:23:55 +1100

> [IPSEC]: Move all calls to xfrm_audit_state_icvfail to xfrm_input
>     
> Let's nip the code duplication in the bud :)
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
