From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Fri, 19 Nov 2004 22:35:27 -0800
Message-ID: <20041119223527.1f243d6e.davem@davemloft.net>
References: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
	<E1CUAQ2-0002jT-00@gondolin.me.apana.org.au>
	<20041116163106.3b62a39a.davem@davemloft.net>
	<Pine.LNX.4.58.0411191755160.2567@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0411191755160.2567@w-sridhar.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Nov 2004 18:00:21 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> Unfortunately as we cannot upgrade to 2.6.10-rc2

This doesn't work.  You cannot expect upstream maintainers
to work with you if you're not willing to or able to
try things out with the latest kernels.

I have an inkling as to the reason why you're restricted
in this way, which is that you're limited to some vendor's
kernel.  Am I right?

In that case, work with the vendor unless you can find some
way to remove the lack of flexibility you have in using newer
kernels.
