From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Current 2.6.x TSO state
Date: Sun, 3 Oct 2004 14:50:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003145024.158b4382.davem@davemloft.net>
References: <20040930213221.06a3f5b3.davem@davemloft.net>
	<20041001130609.GA6979@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ak@suse.de, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041001130609.GA6979@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Oct 2004 23:06:09 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Sep 30, 2004 at 09:32:21PM -0700, David S. Miller wrote:
> > 
> > diff4) Obey MSS in tso handling, shrink tcp_skb_cb
> 
> This looks great.  But can we please rename tcp_skb_psize to
> tcp_skb_mss?

Sure, no problem, I've done that in my tree.
