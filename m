From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Verify key payload in verify_one_algo
Date: Fri, 20 May 2005 07:34:13 +1000
Message-ID: <20050519213413.GA24024@gondor.apana.org.au>
References: <20050519020302.GA20285@gondor.apana.org.au> <20050519021505.GA20703@gondor.apana.org.au> <20050519.124059.85410159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050519.124059.85410159.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2005 at 12:40:59PM -0700, David S. Miller wrote:
> 
> I gather from these two patches that once you found the
> first problem you went around auditing alg_key_len usage
> and these were the only two bugs you spotted.  Right?

Correct.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
