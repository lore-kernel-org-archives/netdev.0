From: David Miller <davem@davemloft.net>
Subject: Re: ipsec: Remove useless ret variable
Date: Fri, 26 Dec 2008 01:31:28 -0800 (PST)
Message-ID: <20081226.013128.258001739.davem@davemloft.net>
References: <20081224053724.GA23476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60027
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753407AbYLZJbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:31:25 -0500
In-Reply-To: <20081224053724.GA23476@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 24 Dec 2008 16:37:24 +1100

> ipsec: Remove useless ret variable
> 
> This patch removes a useless ret variable from the IPv4 ESP/UDP
> decapsulation code.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
