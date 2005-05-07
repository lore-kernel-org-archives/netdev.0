From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/7] [IPSEC] IPsec event notification
Date: Sat, 7 May 2005 17:14:34 +1000
Message-ID: <20050507071434.GA5716@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050409105452.GA7171@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi:

I'm reposting the series of IPsec events patches that I will be asking
Andrew to include in mm.  It's mostly the same as what's been posted
before with some new white space clean-up's and a change to the xfrm
delete sa/policy notification.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
