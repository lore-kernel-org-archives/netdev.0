From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Store idev entries
Date: Tue, 3 May 2005 22:16:46 -0700
Message-ID: <20050503221646.4a8de611.davem@davemloft.net>
References: <4272EC95.20401@miyazawa.org>
	<20050430.120736.45974367.yoshfuji@linux-ipv6.org>
	<20050430031159.GA24326@gondor.apana.org.au>
	<20050430082339.GA20338@gondor.apana.org.au>
	<20050430114349.GA24573@gondor.apana.org.au>
	<20050503162628.7541807d.davem@davemloft.net>
	<42782025.3010700@trash.net>
	<20050504011204.GA19740@gondor.apana.org.au>
	<4278234B.2080605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
        kazunori@miyazawa.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4278234B.2080605@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 04 May 2005 03:20:11 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Herbert Xu wrote:
> > Hmm, I wonder why I didn't see this.  Anyway, could you please add
> > the include to addrconf.h instead?
> 
> Sure, I missed the includes below and thought users of the file were
> supposed to include it first.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks guys.
