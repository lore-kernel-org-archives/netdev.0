From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] [NET] gso: Add skb_is_gso
Date: Sat, 08 Jul 2006 13:35:07 -0700 (PDT)
Message-ID: <20060708.133507.85839172.davem@davemloft.net>
References: <20060708035301.GA5351@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61601
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030351AbWGHUf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 16:35:27 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060708035301.GA5351@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 8 Jul 2006 13:53:02 +1000

> These two patches fix the netfilter/checksum/TSO problem where netfilter
> destroys the partial checksum which breaks TSO.

Both applied, thanks Herbert.
