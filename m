From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: IPSEC xfrm events
Date: 01 Apr 2005 08:18:37 -0500
Message-ID: <1112361517.1089.197.camel@jzny.localdomain>
References: <1112319441.1089.83.camel@jzny.localdomain>
	 <20050401042106.GA27762@gondor.apana.org.au>
	 <1112353398.1096.116.camel@jzny.localdomain>
	 <20050401114258.GA2932@gondor.apana.org.au>
	 <1112358278.1096.160.camel@jzny.localdomain>
	 <20050401123554.GA3468@gondor.apana.org.au>
	 <1112360379.1096.193.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1112360379.1096.193.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-04-01 at 07:59, jamal wrote:

> Let me review first. If it is valuable (we may have to leave expire
> alone). 

Ok, from a first review I would agree with you the result of doing it in
km user will be more maintainable. It will result in a larger patch
but in the long run more maintainable.

> If i can get it done within next day or two fine - else if i get
> busyed out elsewhere i will hand it to you. 

Let me code away at it - The offer still stands though ;->

cheers,
jamal
