From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Tue, 21 Jun 2005 13:21:19 -0700 (PDT)
Message-ID: <20050621.132119.85686894.davem@davemloft.net>
References: <20050603.122558.88474819.davem@davemloft.net>
	<1118139072.2198.119.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gnb@melbourne.sgi.com
In-Reply-To: <1118139072.2198.119.camel@hole.melbourne.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Greg Banks <gnb@melbourne.sgi.com>
Date: Tue, 07 Jun 2005 20:11:12 +1000

> This patch seems to run well, so far without the lockup we saw
> with the first version.  It really helps with irq fairness when
> we have lots of tg3 and Fibre Channel HBA interrupts going to the
> same CPU.

A belated thank you for testing Greg.
