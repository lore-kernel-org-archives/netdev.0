From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: axienet: Fix compilation error
Date: Thu, 13 Feb 2014 18:08:00 -0500 (EST)
Message-ID: <20140213.180800.778415248437011159.davem@davemloft.net>
References: <cover.1392275432.git.michal.simek@xilinx.com>
	<cover.1392275432.git.michal.simek@xilinx.com>
	<2082312fdbceca394080302b1709a5f71d7d3652.1392275432.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthokal@xilinx.com, monstr@monstr.eu,
	anirudh@xilinx.com, John.Linn@xilinx.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2082312fdbceca394080302b1709a5f71d7d3652.1392275432.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Thu, 13 Feb 2014 08:10:42 +0100

> Add missing header to fix compilation error.
> drivers/net/ethernet/xilinx/xilinx_axienet_main.c:1575:22:
>  error: undefined identifier 'irq_of_parse_and_map'
> drivers/net/ethernet/xilinx/xilinx_axienet_main.c:1576:22:
>  error: undefined identifier 'irq_of_parse_and_map'
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied.
