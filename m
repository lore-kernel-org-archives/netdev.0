From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Move xfrm4_rcv export to its site
Date: Mon, 1 Nov 2004 16:59:10 -0800
Message-ID: <20041101165910.138a0f94.davem@davemloft.net>
References: <20041029021352.GA22550@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041029021352.GA22550@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 12:13:52 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a trivial patch that moves xfrm4_rcv's export to the
> site of its definition.  Currently it lives in net/xfrm which
> is miles away.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
