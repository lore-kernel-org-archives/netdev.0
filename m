From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NETLINK] Remove netlink_sock_nr
Date: Wed, 27 Oct 2004 15:32:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027053208.GA8971@gondor.apana.org.au>
References: <20041027051107.GA8784@gondor.apana.org.au> <20041027.141738.132559035.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20041027.141738.132559035.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2004 at 02:17:38PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Alternatively, how about enclosing them with NETLINK_REFCNT_DEBUG
> for future reference?

Well if we really wanted to do refcnt debugging there then there are
much better ways to do it than this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
