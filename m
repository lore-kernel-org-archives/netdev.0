From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Infrahip] [PATCH] Host Identity Protocol
Date: Wed, 23 Mar 2005 02:57:01 +0900 (JST)
Message-ID: <20050323.025701.31052798.yoshfuji@linux-ipv6.org>
References: <20050321.024241.67451836.yoshfuji@linux-ipv6.org>
	<20050320200356.5f8fa583.davem@davemloft.net>
	<Pine.GSO.4.58.0503221531020.19531@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gurtov@cs.helsinki.fi, netdev@oss.sgi.com,
        infrahip@hiit.fi, yoshfuji@linux-ipv6.org
To: miika@iki.fi
In-Reply-To: <Pine.GSO.4.58.0503221531020.19531@kekkonen.cs.hut.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.58.0503221531020.19531@kekkonen.cs.hut.fi> (at Tue, 22 Mar 2005 16:08:31 +0200 (EET)), Miika Komu <miika@iki.fi> says:

> will have to get back to you later with some figures. If the results show
> that an userspace implementation is superior to a kernel based approach in
> terms of security or performance, we may have rewrite the code to the

And, IMHO, the most important argument is, probably, in terms of
simplicity and universality of kernel part.
e.g. MIP6 uses XFRM / stackable destination architecture as its
fundamental infrastructure.

They (simplicity and universality) are unlikely measurable, though.


> justify the reasons by analyzing and measuring. In addition, security
> issues (DoS protection, user supplied public keys, etc) are taken pretty
> seriously in HIP and may benefit from a kernel oriented approach.

I belive that we can find solutions to solve these issues (if any).

--yoshfuji
