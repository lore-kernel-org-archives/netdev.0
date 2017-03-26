From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] padata: avoid race in reordering
Date: Sun, 26 Mar 2017 11:11:45 +0800
Message-ID: <20170326031145.GA19335@gondor.apana.org.au>
References: <CAHmME9oLWiprOyZXo7zvGm7xq+1Kchw9ybLS_TM-9xDyHF0mxQ@mail.gmail.com>
 <20170323112443.30843-1-Jason@zx2c4.com>
 <20170324094157.GE5279@secunet.com>
 <20170325.200151.245940842455044501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, Jason@zx2c4.com,
        linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170325.200151.245940842455044501.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 25, 2017 at 08:01:51PM -0700, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Fri, 24 Mar 2017 10:41:59 +0100
> 
> > On Thu, Mar 23, 2017 at 12:24:43PM +0100, Jason A. Donenfeld wrote:
> >> Under extremely heavy uses of padata, crashes occur, and with list
> >> debugging turned on, this happens instead:
>  ...
> >> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> > 
> > Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Herbert, this should probably go via your crypto tree.

Thanks David.  It's already in the crypto tree.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
