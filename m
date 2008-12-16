From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Mon, 15 Dec 2008 23:44:43 -0800 (PST)
Message-ID: <20081215.234443.193581925.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPh-0003ZC-NS@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38028
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751410AbYLPHom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:44:42 -0500
In-Reply-To: <E1LBJPh-0003ZC-NS@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Dec 2008 12:35:25 +1100

> ethtool: Add GGRO and SGRO ops
> 
> This patch adds the ethtool ops to enable and disable GRO.  It also
> makes GRO depend on RX checksum offload much the same as how TSO
> depends on SG support.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
