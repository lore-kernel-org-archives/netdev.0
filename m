From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Make ah4/esp4/ipcomp depend on INET
Date: Mon, 1 Nov 2004 16:59:58 -0800
Message-ID: <20041101165958.674c0485.davem@davemloft.net>
References: <20041029033900.GA23206@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041029033900.GA23206@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 13:39:00 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> As it is someone could disable INET and still enable ah4/esp4/ipcomp.
> This patch adds the dependency on INET to prevent this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert.
