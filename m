From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/8] net/macb: fixes after big driver update
Date: Tue, 31 Mar 2015 16:52:16 -0400 (EDT)
Message-ID: <20150331.165216.1751909468171592817.davem@davemloft.net>
References: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com,
	cyrille.pitchen@atmel.com, alexandre.belloni@free-electrons.com,
	michal.simek@xilinx.com, punnaia@xilinx.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Tue, 31 Mar 2015 15:01:58 +0200

> The recent modifications to the macb driver lead to issues with the probe
> function code flow. Here are some attempt to fix them.
> This time, some more issues are fixed related to the clock as reported by Boris
> Brezillon.
> 
> The series is written on top of net-next.
> 
> Changes in v2:
> - address Cyrille comment about exit condition of queue configuration loop
> - add fixes for probe sequence related to clocks
> - add ethtool register dump
> - fix peripheral version test

Series applied, thanks.
