From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Mon, 1 Mar 2010 16:33:37 +0100
Message-ID: <20100301153337.GA20508@secunet.com>
References: <1267017564.3973.790.camel@bigi>
 <20100225104029.GB3927@gauss.dd.secunet.de>
 <1267103990.3973.942.camel@bigi>
 <1267366035.24915.24.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:43039 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab0CAPdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 10:33:15 -0500
Content-Disposition: inline
In-Reply-To: <1267366035.24915.24.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal.

On Sun, Feb 28, 2010 at 09:07:15AM -0500, jamal wrote:
> Steffen,
> 
> Did you try the simple patch i posted? After contemplating
> in the background i think it is the right thing to do.
> Ive also fixed IPV6 side the same way.
> 

Yes, I did. Your patch works fine. As your solution is less
invasive we probaply should take your patches if nobody else
has an opinion on this.

Steffen
