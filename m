From: jamal <hadi@cyberus.ca>
Subject: Re: [2/4] [IPSEC] Kill spurious hard expire messages
Date: 11 Apr 2005 07:57:29 -0400
Message-ID: <1113220648.1090.364.camel@jzny.localdomain>
References: <1112702604.1089.119.camel@jzny.localdomain>
	 <20050409105452.GA7171@gondor.apana.org.au>
	 <20050409111244.GB7171@gondor.apana.org.au>
	 <1113049844.1090.23.camel@jzny.localdomain>
	 <20050409192926.GA9423@gondor.apana.org.au>
	 <20050409200306.GA9660@gondor.apana.org.au>
	 <1113142244.1088.287.camel@jzny.localdomain>
	 <20050410212707.GA30337@gondor.apana.org.au>
	 <1113218420.1090.351.camel@jzny.localdomain>
	 <20050411113040.GA25718@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050411113040.GA25718@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert,

On Mon, 2005-04-11 at 07:30, Herbert Xu wrote:
> Hi Jamal:

> Therefore knowing that xfrm_policy_delete returned 0 implies that
> no user-initiated delete action can succeed either before or after
> the expire event.
> 

Ok, what you are saying is sensible, but: does this mean there was never
an issue then there was never a possibility of delete and expire
intefering with each other then?

cheers,
jamal
