From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skbuff: Fix checksum start check in skb_postpull_rcsum
Date: Thu, 1 Oct 2015 23:15:43 +0800
Message-ID: <20151001151543.GB28373@gondor.apana.org.au>
References: <1443698177.3401.1.camel@gmail.com>
 <20151001112134.GA26657@gondor.apana.org.au>
 <20151001113407.GA26772@gondor.apana.org.au>
 <20151001.081543.1685933972558161717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: umgwanakikbuti@gmail.com, netdev@vger.kernel.org,
	pshelar@nicira.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151001.081543.1685933972558161717.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 01, 2015 at 08:15:43AM -0700, David Miller wrote:
> 
> A patch with this and more should be in the 'net' tree already.

Yes this looks much better.  Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
