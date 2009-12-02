From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] crypto: gmac - Add RFC4543 wrapper for GCM
Date: Wed, 2 Dec 2009 08:53:29 +0800
Message-ID: <20091202005329.GB1828@gondor.apana.org.au>
References: <4B154918.7070008@strongswan.org> <20091201.155141.147973233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tobias@strongswan.org, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091201.155141.147973233.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 01, 2009 at 03:51:41PM -0800, David Miller wrote:
> From: Tobias Brunner <tobias@strongswan.org>
> Date: Tue, 01 Dec 2009 17:49:28 +0100
> 
> > This patch adds the RFC4543 (GMAC) wrapper for GCM similar to the
> > existing RFC4106 wrapper. The main differences between GCM and GMAC are
> > the contents of the AAD and that the plaintext is empty for the latter.
> > 
> > Signed-off-by: Tobias Brunner <tobias@strongswan.org>
> 
> Herbert, you got this one?

Sure I'll pick it up.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
