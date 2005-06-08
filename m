From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Thu, 9 Jun 2005 08:10:47 +1000
Message-ID: <20050608221047.GA12920@gondor.apana.org.au>
References: <20050606.210846.07641049.davem@davemloft.net> <200506081740.11292.jheffner@psc.edu> <20050608.144906.77057282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jheffner@psc.edu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050608.144906.77057282.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2005 at 02:49:06PM -0700, David S. Miller wrote:
> 
> Performance went down, with both TSO enabled and disabled, compared to
> not having the patches applied.

What was the receiver running? Was the performance degradation more
pronounced with TSO enabled?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
