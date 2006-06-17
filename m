From: David Miller <davem@davemloft.net>
Subject: Re: [ETHTOOL]: Fix UFO typo
Date: Fri, 16 Jun 2006 19:53:37 -0700 (PDT)
Message-ID: <20060616.195337.15807471.davem@davemloft.net>
References: <20060616063905.GA32669@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:12457
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751588AbWFQCxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 22:53:14 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060616063905.GA32669@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 16 Jun 2006 16:39:05 +1000

> [ETHTOOL]: Fix UFO typo
> 
> The function ethtool_get_ufo was referring to ETHTOOL_GTSO instead of
> ETHTOOL_GUFO.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch Herbert, I'll apply this as soon as I get a chance.
