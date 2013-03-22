From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 11:41:59 -0400 (EDT)
Message-ID: <20130322.114159.2303026992656610194.davem@davemloft.net>
References: <FE78128C-01DB-4831-ACBE-BA3E3A428BFC@gmail.com>
	<20130322.111759.2108472348146991505.davem@davemloft.net>
	<9AEAD974-4549-475A-AE15-C92523CD2466@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: benmcollins13@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9AEAD974-4549-475A-AE15-C92523CD2466@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Collins <benmcollins13@gmail.com>
Date: Fri, 22 Mar 2013 11:39:20 -0400

> If your company had hardware going to production, you'd want it
> supported in mainline too, I suspect.

But never against the wishes of the author of the code.

This has firm and strict precedence, for example one of the
implementations block layer encryption was not wanted to be merged by
the author, and Linus reverted it.

So if the person who wrote the code doesn't want it upstream, you can't
bypass them against their wishes, ever.  It's their code not your's.
