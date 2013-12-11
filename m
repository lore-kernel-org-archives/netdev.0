From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] net: macb updates
Date: Tue, 10 Dec 2013 22:57:12 -0500 (EST)
Message-ID: <20131210.225712.1516913784424835912.davem@davemloft.net>
References: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, michal.simek@xilinx.com
To: soren.brinkmann@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Date: Tue, 10 Dec 2013 16:07:18 -0800

> I'd really like to have Ethernet working for Zynq, so I want to at least
> revive this discussion regarding this patchset. And the first four
> patches should not even be too controversial.
> I didn't change anything compared to my original RFC submission, except
> for a typo in one of the commit messages.
> Handling the tx_clk as optional clock input seems a little bit weird,
> but it works on my Zynq platform and should be compatible with other
> users of macb and their DT descriptions.

Series applied to net-next, thanks.
