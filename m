From: jamal <hadi@cyberus.ca>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: 03 Apr 2005 23:05:12 -0400
Message-ID: <1112583912.1096.429.camel@jzny.localdomain>
References: <1112403845.1088.14.camel@jzny.localdomain>
	 <20050402012813.GA24575@gondor.apana.org.au>
	 <1112406164.1088.54.camel@jzny.localdomain>
	 <20050402014619.GB24861@gondor.apana.org.au>
	 <1112469601.1088.173.camel@jzny.localdomain>
	 <1112538718.1096.394.camel@jzny.localdomain>
	 <20050404005805.GA16543@gondor.apana.org.au>
	 <1112579761.1096.412.camel@jzny.localdomain>
	 <20050404022601.GA17293@gondor.apana.org.au>
	 <1112582396.1096.427.camel@jzny.localdomain>
	 <20050404024600.GA17507@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404024600.GA17507@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-03 at 22:46, Herbert Xu wrote:

> Even if we do eventually open up netlink for non-root listeners
> (this will actually require structural changes to netlink itself),
> we can create a new multicast group for non-privileged users that
> don't get the keys.
> 

Ok, I will add the keys in the case of the netlink announce.

cheers,
jamal
