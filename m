From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Netfilter+IPsec
Date: Wed, 23 Mar 2005 21:43:40 -0800
Message-ID: <20050323214340.70a1c950.davem@davemloft.net>
References: <20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
	<20050318104013.57d65e99.davem@davemloft.net>
	<423D9ADA.6050407@trash.net>
	<20050322194910.6a9fa3a4.davem@davemloft.net>
	<4240EA78.5050402@trash.net>
	<42424AAE.9080403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42424AAE.9080403@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Mar 2005 06:05:50 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch (not entirely reviewed myself yet) contains the parts
> necessary for hooking output IPsec packets for netfilter.

This is actually much cleaner than I had ever anticipated.
I like it.

I suppose the input side will be quite a bit more involved?
