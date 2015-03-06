From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: macb: Fix multi queue support for xilinx
 ZynqMP
Date: Fri, 06 Mar 2015 15:48:28 -0500 (EST)
Message-ID: <20150306.154828.1539223935494024045.davem@davemloft.net>
References: <299bfd8acf19df0b4407f98caf5130c1823cf8ad.1425662901.git.michal.simek@xilinx.com>
	<299bfd8acf19df0b4407f98caf5130c1823cf8ad.1425662901.git.michal.simek@xilinx.com>
	<d7fb06d16c8139004cf8f580c30b1078d2eb8086.1425662901.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, monstr@monstr.eu,
	punnaiah.choudary.kalluri@xilinx.com, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d7fb06d16c8139004cf8f580c30b1078d2eb8086.1425662901.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Fri,  6 Mar 2015 18:29:12 +0100

> From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>
> 
> ZynqMP soc has single interrupt for all the queue events. So,
> passing the IRQF_SHARED flag for interrupt registration call.
> 
> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied.
