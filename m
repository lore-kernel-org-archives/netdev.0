From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [TCP] Move tcp_get_info out of tcp_diag
Date: Tue, 26 Oct 2004 12:42:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026124243.6dd71e9f.davem@davemloft.net>
References: <20041026045701.GA10365@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041026045701.GA10365@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 26 Oct 2004 14:57:01 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch move tcp_get_info from tcp_diag.c into
> the site of the other caller, tcp.c.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
