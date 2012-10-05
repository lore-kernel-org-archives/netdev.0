From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Fri, 05 Oct 2012 00:36:35 -0700
Message-ID: <1349422595.2008.55.camel@joe-AO722>
References: <CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>
	 <20121004.142335.1467206545795435493.davem@davemloft.net>
	 <CA+MoWDqBF5bdQYBaUmpB99Q=YcHYcUxi8Ffo3x4s0B+pmomb+Q@mail.gmail.com>
	 <20121004.145419.1859367129463136197.davem@davemloft.net>
	 <1349395795.2008.26.camel@joe-AO722>
	 <alpine.DEB.2.02.1210050712590.1958@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, peter.senna@gmail.com,
	shemminger@vyatta.com, mlindner@marvell.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1210050712590.1958@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-05 at 07:22 +0200, Julia Lawall wrote:
> A tool was used to find a potential problem, and then Peter
> studied the code to see what fix was appropriate.

Hi Julia.

Was it true that a static analysis tool found the original
potential issue?  If so, what tool was it?

But wasn't the scripted fix applied to the rest of the tree
robotically?
