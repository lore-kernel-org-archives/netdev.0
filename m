From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IP6IP6] Handle ECN correctly
Date: Wed, 8 Sep 2004 21:40:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908214023.08dec350.davem@davemloft.net>
References: <20040909034508.GA19547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, vnourval@tcs.hut.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040909034508.GA19547@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 13:45:08 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch adds ECN encapsulation/decapsulation to ip6_tunnel.c.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

How are those TTL encap fixes coming along? ;-)
