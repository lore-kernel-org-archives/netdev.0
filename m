From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Added GSO header verification
Date: Tue, 27 Jun 2006 13:22:57 -0700 (PDT)
Message-ID: <20060627.132257.48805004.davem@davemloft.net>
References: <20060627120714.GA15270@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8876
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030348AbWF0UW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:22:57 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060627120714.GA15270@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 27 Jun 2006 22:07:14 +1000

> This feature is only needed by Xen but most of the code here is useful
> for other things like TCPv4 ECN support.
> 
> [NET]: Added GSO header verification

Looks sane, applied.

Thanks Herbert.
