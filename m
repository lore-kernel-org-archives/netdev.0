From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the final tree (net
 tree related)
Date: Tue, 15 Jun 2010 21:44:06 -0700 (PDT)
Message-ID: <20100615.214406.45904170.davem@davemloft.net>
References: <20100616134848.3edd4a25.sfr@canb.auug.org.au>
	<20100616035630.GB17440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100616035630.GB17440@gondor.apana.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 16 Jun 2010 13:56:30 +1000

> bridge: Add const to dummy br_netpoll_send_skb
> 
> The version of br_netpoll_send_skb used when netpoll is off is
> missing a const thus causing a warning.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
