From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/3] [PPP] L2TP: Disallow non-UDP datagram sockets
Date: Tue, 18 Sep 2007 21:16:20 +0100
Message-ID: <46F03214.6000601@katalix.com>
References: <20070918120438.GA9121@gondor.apana.org.au> <E1IXbqW-0002OB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michal Ostrowski <mostrows@speakeasy.net>,
	Paul Mackerras <paulus@samba.org>,
	=?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:50538 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754707AbXIRUQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 16:16:37 -0400
In-Reply-To: <E1IXbqW-0002OB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> [PPP] L2TP: Disallow non-UDP datagram sockets
> 
> With the addition of UDP-Lite we need to refine the socket check so that
> only genuine UDP sockets are allowed through.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: James Chapman <jchapman@katalix.com>

