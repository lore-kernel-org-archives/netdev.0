From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Show all SYN_RECV sockets in /proc/net/tcp
Date: Tue, 5 Oct 2004 22:18:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005221836.4b1281db.davem@davemloft.net>
References: <20041006020650.GA14583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041006020650.GA14583@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Oct 2004 12:06:50 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I was fixing the tcp_diag so that it shows SYN_RECV sockets properly.
> I found that /proc/net/tcp didn't do it correctly either.  So here is
> a small patch to fix /proc/net/tcp.
> 
> The logic in there stinks though so I'd love to see a rewrite.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Patch applied, thanks.  And yes I agree this stuff could
be improved dramatically.
