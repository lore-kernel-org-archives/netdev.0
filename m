From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Current 2.6.x TSO state
Date: Fri, 1 Oct 2004 23:06:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001130609.GA6979@gondor.apana.org.au>
References: <20040930213221.06a3f5b3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, ak@suse.de, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040930213221.06a3f5b3.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 30, 2004 at 09:32:21PM -0700, David S. Miller wrote:
> 
> diff4) Obey MSS in tso handling, shrink tcp_skb_cb

This looks great.  But can we please rename tcp_skb_psize to
tcp_skb_mss?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
