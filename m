From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Modularise tcpdiag
Date: Mon, 1 Nov 2004 17:01:45 -0800
Message-ID: <20041101170145.52185904.davem@davemloft.net>
References: <20041029043858.GA27907@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041029043858.GA27907@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 14:38:58 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is the first step in fixing the tcpdiag/modular ipv6 issue.
> We modularise tcpdiag in the obvious way.
> 
> Next we can move out the IPv6-specific stuff.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
