From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] : bug fix in multipath drr code.
Date: Thu, 26 May 2005 15:13:29 -0700 (PDT)
Message-ID: <20050526.151329.21592585.davem@davemloft.net>
References: <4292CDCE.2090600@calsoftinc.com>
	<20050524071146.GA30995@gondor.apana.org.au>
	<4292FA7C.80308@calsoftinc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pravins@calsoftinc.com
In-Reply-To: <4292FA7C.80308@calsoftinc.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: pravin b shelar <pravins@calsoftinc.com>
Date: Tue, 24 May 2005 15:27:16 +0530

> So I think we should ignore MULTIPATHOLDROUTE flag
> in drr and rr multipath algorithms as done in random multipath algorithm.
> 
> Attached patch does same thing.

I've applied this patch, thanks.
