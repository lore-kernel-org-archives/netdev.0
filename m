From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Disable queueing when carrier is lost (take 2)
Date: Wed, 4 May 2005 09:10:23 +1000
Message-ID: <20050503231023.GA18323@gondor.apana.org.au>
References: <4276B13F.2040103@tpack.net> <20050503100306.GB29788@gondor.apana.org.au> <4277FC16.4050307@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <4277FC16.4050307@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 04, 2005 at 12:32:54AM +0200, Tommy Christensen wrote:
> 
> Anyway, given the comments from Thomas, I've pulled out the IFF_RUNNING
> stuff. We can add this later, when the other uses have been sorted out.

Thanks Tommy.  This version looks good to me.  BTW, you probably
should add a Signed-off-by line.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
