From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Remove tcp_pcount_t
Date: Mon, 17 Jan 2005 14:39:35 -0800
Message-ID: <20050117143935.6b141791.davem@davemloft.net>
References: <20050117101058.GA27521@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050117101058.GA27521@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Jan 2005 21:10:58 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> IMHO the TSO stuff has mostly settled down now.  As a result
> tcp_pcount_t is now more of a liability in that it reduces the
> readability of the code.
> 
> So here is a patch to remove it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Agreed and applied, thanks Herbert.
