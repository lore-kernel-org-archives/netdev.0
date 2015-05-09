From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 4/4] net: macb: Add change_mtu callback
 with jumbo support
Date: Sat, 09 May 2015 17:43:40 -0400 (EDT)
Message-ID: <20150509.174340.2051611421730551398.davem@davemloft.net>
References: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
	<1430931438-32592-4-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, harinikatakamlinux@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, harinik@xilinx.com, punnaia@xilinx.com,
	michals@xilinx.com
To: harini.katakam@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430931438-32592-4-git-send-email-harinik@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harini Katakam <harini.katakam@xilinx.com>
Date: Wed, 6 May 2015 22:27:18 +0530

> Add macb_change_mtu callback; if jumbo frame support is present allow
> mtu size changes upto (jumbo max length allowed - headers).
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>

Applied.
