From: jamal <hadi@cyberus.ca>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: 03 Apr 2005 22:39:56 -0400
Message-ID: <1112582396.1096.427.camel@jzny.localdomain>
References: <1112358278.1096.160.camel@jzny.localdomain>
	 <20050401123554.GA3468@gondor.apana.org.au>
	 <1112403845.1088.14.camel@jzny.localdomain>
	 <20050402012813.GA24575@gondor.apana.org.au>
	 <1112406164.1088.54.camel@jzny.localdomain>
	 <20050402014619.GB24861@gondor.apana.org.au>
	 <1112469601.1088.173.camel@jzny.localdomain>
	 <1112538718.1096.394.camel@jzny.localdomain>
	 <20050404005805.GA16543@gondor.apana.org.au>
	 <1112579761.1096.412.camel@jzny.localdomain>
	 <20050404022601.GA17293@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404022601.GA17293@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-03 at 22:26, Herbert Xu wrote:
> On Sun, Apr 03, 2005 at 09:56:01PM -0400, jamal wrote:

> > I dont think we should broadcast out keys. 
> 
> I think that decision should be made by the KM.  So you wouldn't do it
> for PFKEY, but netlink should definitely do it.
> 

Is it possible to have non-root privileged pfkey sockets. If yes,
then it makes sense.

> Yes unless you're using elvis :)

Elvis left the building a while back ;->
But sightings of him in some doughnought shops in a small town not far
from here are rampant ;->

> The code above is in pfkey_spdget().
> 

How did i miss that? ;-> 

cheers,
jamal
