From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ll_temac: Remove sparse warnings
Date: Sun, 07 Jun 2015 15:21:04 -0700 (PDT)
Message-ID: <20150607.152104.1816869275923133948.davem@davemloft.net>
References: <343ee9fccc37629414209d4c05077eb52aed8ed2.1433494150.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, monstr@monstr.eu,
	soren.brinkmann@xilinx.com, fabf@skynet.be,
	manuel.schoelling@gmx.de, julia.lawall@lip6.fr,
	netdev@vger.kernel.org, elfring@users.sourceforge.net,
	subbaraya.sundeep.bhatta@xilinx.com,
	linux-arm-kernel@lists.infradead.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <343ee9fccc37629414209d4c05077eb52aed8ed2.1433494150.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Fri,  5 Jun 2015 10:49:17 +0200

> Remove sparse warnings:
> drivers/net/ethernet/xilinx/ll_temac_main.c:65:16: warning: cast removes
> address space of expression
> drivers/net/ethernet/xilinx/ll_temac_main.c:70:9: warning: cast removes
> address space of expression
> drivers/net/ethernet/xilinx/ll_temac_main.c:127:16: warning: cast
> removes address space of expression
> drivers/net/ethernet/xilinx/ll_temac_main.c:137:9: warning: cast removes
> address space of expression
> drivers/net/ethernet/xilinx/ll_temac_main.c:409:3: warning: symbol
> 'temac_options' was not declared. Should it be static?
> drivers/net/ethernet/xilinx/ll_temac_main.c:590:6: warning: symbol
> 'temac_adjust_link' was not declared. Should it be static?
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied, thank you.
