From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [INET] Kill ip6_get_dsfield
Date: Thu, 16 Sep 2004 13:26:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916132637.69a07e57.davem@davemloft.net>
References: <20040916115827.GA29046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040916115827.GA29046@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Sep 2004 21:58:28 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch kills the duplicate implementation of ip6_get_dsfield in
> inet_ecn.h.  It now uses ipv6_get_dsfield from dsfield.h instead.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
