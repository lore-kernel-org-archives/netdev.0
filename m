From: David Miller <davem@davemloft.net>
Subject: Re: [FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge
Date: Tue, 20 Jun 2006 00:10:35 -0700 (PDT)
Message-ID: <20060620.001035.10245408.davem@davemloft.net>
References: <20060620070450.GA12609@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, torvalds@osdl.org, netdev@vger.kernel.org,
	aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10157
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964962AbWFTHKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 03:10:30 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060620070450.GA12609@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Jun 2006 17:04:50 +1000

> [FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge

Thanks for checking out that merge conflict.

Linus, please apply.
