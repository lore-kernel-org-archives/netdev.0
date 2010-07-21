From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linux-next: manual merge of the net tree with Linus' tree
Date: Wed, 21 Jul 2010 10:31:15 +0800
Message-ID: <20100721023114.GA14529@gondor.apana.org.au>
References: <20100721120448.31e325fd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100721120448.31e325fd.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 21, 2010 at 12:04:48PM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> net/bridge/br_device.c between commit
> 573201f36fd9c7c6d5218cdcd9948cee700b277d ("bridge: Partially disable
> netpoll support") from Linus' tree and commit
> 91d2c34a4eed32876ca333b0ca44f3bc56645805 ("bridge: Fix netpoll support")
> from the net tree.
> 
> The net tree commit seems to be a fuller fix, so I used that.

Yeah, 573201f is just the temporary fix for 2.6.35.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
