From: David Miller <davem@davemloft.net>
Subject: Re: tcp: Unexport TCPv6 GRO functions
Date: Fri, 22 May 2009 00:45:38 -0700 (PDT)
Message-ID: <20090522.004538.228123397.davem@davemloft.net>
References: <20090522071944.GA23355@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751791AbZEVHpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 03:45:39 -0400
In-Reply-To: <20090522071944.GA23355@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 May 2009 17:19:44 +1000

> tcp: Unexport TCPv6 GRO functions
> 
> Sinec the TCPv6 GRO functions are used in the same file where
> they are defined, we do not need to export them.  This was a
> cut-n-paste from the IPv4 code which does need to export them.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
