From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch2: del/get byid
Date: Thu, 28 Apr 2005 12:14:26 +1000
Message-ID: <20050428021426.GA23415@gondor.apana.org.au>
References: <1114654284.7663.50.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114654284.7663.50.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 10:11:24PM -0400, jamal wrote:
> 
> This is definetely a bug. It doesnt seem like get/del by index worked.
> For some reason i thought i tested this before and it worked.

Why is this a bug? Have you checked xfrm_gen_index?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
