From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sun, 15 Aug 2004 19:59:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815195952.61f8a29b.davem@redhat.com>
References: <20040812165954.00429e65.davem@redhat.com>
	<20040813090314.448c971d@dell_ss3.pdx.osdl.net>
	<20040813093838.6961c0d4.davem@redhat.com>
	<20040813215602.GA15870@gondor.apana.org.au>
	<20040813151923.3311b4f0.davem@redhat.com>
	<20040814003428.GA17760@gondor.apana.org.au>
	<20040813173924.6d05be15.davem@redhat.com>
	<20040814005411.GA18350@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040814005411.GA18350@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 14 Aug 2004 10:54:11 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Aug 13, 2004 at 05:39:24PM -0700, David S. Miller wrote:
> > 
> > Yes and I cured the one typo in it two, idev-->in_dev :-)
> 
> Two birds with one stone :)
> 
> Here is a trivial optimisation for irda to since it doesn't hold
> onto the idev.

Applied.
