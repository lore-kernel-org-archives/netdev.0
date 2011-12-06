From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c
Date: Tue, 06 Dec 2011 13:17:10 -0500 (EST)
Message-ID: <20111206.131710.2181211652306186928.davem@davemloft.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: LW@KARO-electronics.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1323163127.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please use a more reasonable Subject line for your patches.

Saying "several cleanups and bugfixes for fec.c:" in every subject
line of a whole series of patches isn't very helpful.

Just "fec: set con_id in clk_get() call to NULL", as one example, would be fine.

You will need to resubmit this entire patch series, afresh, with this fixup.
Do not try to fix it up by replying to the individual patch postings.
