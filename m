From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Set truesize in pskb_expand_head
Date: Sat, 25 Sep 2004 09:37:13 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924233713.GA8001@gondor.apana.org.au>
References: <20040924232053.GA7807@gondor.apana.org.au> <20040924163328.7597352c.davem@davemloft.net> <20040924233555.GA7962@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924233555.GA7962@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 25, 2004 at 09:35:55AM +1000, herbert wrote:
> 
> Dave, it hasn't been charged yet...

Well at least not in the netlink case.  But you're that we can't do this
in general.  I'll adjust it right after the pskb_expand_head call then.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
