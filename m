From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH: IPSEC xfrm events
Date: Sat, 2 Apr 2005 11:45:43 +1000
Message-ID: <20050402014543.GA24861@gondor.apana.org.au>
References: <1112319441.1089.83.camel@jzny.localdomain> <20050401042106.GA27762@gondor.apana.org.au> <1112353398.1096.116.camel@jzny.localdomain> <20050401114258.GA2932@gondor.apana.org.au> <1112358278.1096.160.camel@jzny.localdomain> <20050401123554.GA3468@gondor.apana.org.au> <1112403845.1088.14.camel@jzny.localdomain> <20050402012813.GA24575@gondor.apana.org.au> <1112406164.1088.54.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112406164.1088.54.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2005 at 08:42:45PM -0500, jamal wrote:
> 
> hold on: Ah, I think i may get what you are trying to get to: You want
> iproute to display something along the lines of "this was created by a
> pfkey app pid 1534". Did i read you correctly?

That's right.  Someone with a pathological mind might do pfkey and
netlink from the same pid :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
