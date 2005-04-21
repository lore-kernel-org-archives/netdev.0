From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] Add missing newline for skb_*_panic
Date: Fri, 22 Apr 2005 09:14:37 +1000
Message-ID: <20050421231437.GA10119@gondor.apana.org.au>
References: <20050421050815.GA23133@gondor.apana.org.au> <42682527.3000709@trash.net> <42682718.3060601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42682718.3060601@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 12:20:08AM +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> >How about this one instead? Besides the missing newlines, it adds
> >head/data/tail/end to the output, which can give valuable hints
> >about what happend before.
> 
> While we're at it, lets also replace KERN_INFO by KERN_EMERG to
> make sure the user gets to see it.

Thanks Patrick, this looks great.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
