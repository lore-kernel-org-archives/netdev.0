From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 30 Mar 2005 22:18:55 -0500
Message-ID: <1112239135.1089.50.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194707.GA9872@gondor.apana.org.au>
	 <1111867875.1089.915.camel@jzny.localdomain>
	 <20050327081848.GA13428@gondor.apana.org.au>
	 <1111950449.1089.938.camel@jzny.localdomain>
	 <20050330004903.GA3399@gondor.apana.org.au>
	 <1112237759.1092.35.camel@jzny.localdomain>
	 <20050331030036.GA27309@gondor.apana.org.au>
	 <20050331030145.GA27364@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050331030145.GA27364@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-30 at 22:01, Herbert Xu wrote:

> Actually, could you rename it to km_state_cb? This information is
> only used for communication with the the km and it should be marked
> as such just like the other km_* identifiers.

no problemo. 
[Should be able to post patch for both SP+SA with all 
these changes maybe sometime tommorow. Both Masahide and myself are
doing some testing].

cheers,
jamal
