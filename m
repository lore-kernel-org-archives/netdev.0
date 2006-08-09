From: David Miller <davem@davemloft.net>
Subject: Re: [2/2] [IPV4]: Use network-order dport for all visible
 inet_lookup_*
Date: Wed, 09 Aug 2006 15:47:40 -0700 (PDT)
Message-ID: <20060809.154740.111206880.davem@davemloft.net>
References: <20060808084729.GA8085@gondor.apana.org.au>
	<20060808.022443.62664150.davem@davemloft.net>
	<20060808111140.GA15028@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61393
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751415AbWHIWrx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 18:47:53 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060808111140.GA15028@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Aug 2006 21:11:40 +1000

> Good point.  This patch eliminates the double swap for __inet_lookup.
> 
> [IPV4]: Use network-order dport for all visible inet_lookup_*

Applied, thanks Herbert.
