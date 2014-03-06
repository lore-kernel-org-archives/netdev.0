From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] net: macb: Check DMA mappings for error
Date: Wed, 05 Mar 2014 20:47:47 -0500 (EST)
Message-ID: <20140305.204747.1926579810397332616.davem@davemloft.net>
References: <1393951600-26039-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vinod.koul@intel.com,
	dan.j.williams@intel.com, michal.simek@xilinx.com,
	ben@decadent.org.uk
To: soren.brinkmann@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393951600-26039-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Date: Tue,  4 Mar 2014 08:46:39 -0800

> With CONFIG_DMA_API_DEBUG enabled the following warning is printed:
 ...
> due to missing checks of the dma mapping. Add the appropriate checks to fix
> this.
> 
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>

Applied.
