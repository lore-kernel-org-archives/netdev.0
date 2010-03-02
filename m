From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 2 Mar 2010 15:06:31 +0100
Message-ID: <20100302140631.GD20508@secunet.com>
References: <1267017564.3973.790.camel@bigi>
 <20100302112754.GA1513@gondor.apana.org.au>
 <1267531905.21749.21.camel@bigi>
 <20100302125156.GA2420@gondor.apana.org.au>
 <1267535426.21749.24.camel@bigi>
 <20100302134656.GC20508@secunet.com>
 <1267538070.21749.27.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	kaber@trash.net, yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:45382 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075Ab0CBOGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 09:06:06 -0500
Content-Disposition: inline
In-Reply-To: <1267538070.21749.27.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 08:54:30AM -0500, jamal wrote:
> 
> yikes. Ok. Seems this fix needs to go -stable as well then.

Indeed, it should.

> 
> > I tried it, works for me too.
> 
> Did you try with CONFIG_XFRM_SUB_POLICY=y. Thats the only reason
> i said "looks like it might work". If you tried with that, then
> I dont need to test and I can add an ACKed-by;-> 
> 

Yes, I tested with CONFIG_XFRM_SUB_POLICY=y. 
So for me I can add an
Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

