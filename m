From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Wed, 27 Apr 2005 23:24:17 -0400
Message-ID: <1114658657.7663.110.camel@localhost.localdomain>
References: <1114654284.7663.50.camel@localhost.localdomain>
	 <20050428021426.GA23415@gondor.apana.org.au>
	 <1114655014.7663.61.camel@localhost.localdomain>
	 <20050428022549.GA23556@gondor.apana.org.au>
	 <1114655980.7663.76.camel@localhost.localdomain>
	 <20050428024253.GA23695@gondor.apana.org.au>
	 <1114656932.7663.88.camel@localhost.localdomain>
	 <20050428030325.GB23823@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428030325.GB23823@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 13:03 +1000, Herbert Xu wrote:

> Or we can simply put it in a field called dir and start using it
> instead of passing it around :)
> 

that would be the best option. 

> With respect to the user specifying the index when adding policies,
> I think we should check with Alexey.  He added the original code to
> do this so maybe there was a problem with KAME that makes this
> necessary.
> 

Agreed. Alexey, thread of interest on netdev, this one as well as
other with subject "patch: policy update by id"

cheers,
jamal
