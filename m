From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4] Make loopback idev stick around
Date: Wed, 9 Mar 2005 20:40:01 -0800
Message-ID: <20050309204001.5b5997ad.davem@davemloft.net>
References: <20050205053030.GA17412@gondor.apana.org.au>
	<20050205053532.GA17474@gondor.apana.org.au>
	<20050215144121.702767c5.davem@davemloft.net>
	<20050216101245.GA32341@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050216101245.GA32341@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Feb 2005 21:12:45 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Let's also clean up loopback's ipv6 structure in addrconf_cleanup
> even though it never happens currently :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Seems sane to me.

Applied, thanks Herbert.
