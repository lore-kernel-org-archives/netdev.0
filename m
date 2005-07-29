From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Infrahip] Re: [hipl-users] Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Sat, 30 Jul 2005 09:48:59 +1000
Message-ID: <20050729234859.GA27325@gondor.apana.org.au>
References: <E1Dy6gb-00044G-00@gondolin.me.apana.org.au> <1122651216.25842.67.camel@odysse> <B9CA81E3-5A80-4629-8D32-42A8C37142E2@nomadiclab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: diego.beltrami@HIIT.FI, netdev@oss.sgi.com, infrahip@HIIT.FI
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Nikander <pekka.nikander@nomadiclab.com>
Content-Disposition: inline
In-Reply-To: <B9CA81E3-5A80-4629-8D32-42A8C37142E2@nomadiclab.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 29, 2005 at 05:45:24PM +0200, Pekka Nikander wrote:
> >Surely BEET will work also for AH with minor changes, even though we
> >only tried the ESP encapsulation.
> 
> I wouldn't be so sure.  IIRC, tunnel mode is not specified for AH but  
> for ESP only.  Consequently, defining BEET mode for AH might be  

Well plain tunnel mode certainly is specified for AH as well as IPComp.
But you're right the semantics of BEET mode for AH needs to be thought
out.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
