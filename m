From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Store idev entries (was: [PATCH][IPv6][IPsec] stop
 infinite loop)
Date: Tue, 3 May 2005 16:26:28 -0700
Message-ID: <20050503162628.7541807d.davem@davemloft.net>
References: <4272EC95.20401@miyazawa.org>
	<20050430.120736.45974367.yoshfuji@linux-ipv6.org>
	<20050430031159.GA24326@gondor.apana.org.au>
	<20050430082339.GA20338@gondor.apana.org.au>
	<20050430114349.GA24573@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kazunori@miyazawa.org, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050430114349.GA24573@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Apr 2005 21:43:49 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The ref counting on loopback_idev wasn't quite right.  Here is the
> corrected version.

Applied, thanks Herbert.
