From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2/4] [IPSEC] Add xfrm_state_mtu
Date: Sun, 6 Mar 2005 21:23:28 -0800
Message-ID: <20050306212328.1d71b8a2.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050214221200.GA18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005 09:12:00 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch introduces the function xfrm_state_mtu which calculates
> the MTU under a specific SA.  This function can be simplified once
> we get rid all other uses of get_max_size as we can move the calculation
> into the invidual SA type.

Applied, thanks Herbert.
