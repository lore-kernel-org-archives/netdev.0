From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Protect against BHs in xfrm_user_policy()
Date: Mon, 4 Apr 2005 11:20:40 +1000
Message-ID: <20050404012040.GA16960@gondor.apana.org.au>
References: <4250160D.2040405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4250160D.2040405@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2005 at 06:13:01PM +0200, Patrick McHardy wrote:
>
> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2005/04/03 17:36:10+02:00 kaber@coreworks.de 
> #   [IPSEC]: Protect against BHs in xfrm_user_policy()
> #   
> #   Signed-off-by: Patrick McHardy <kaber@trash.net>

Looks good.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

We want the same thing for km_query, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
