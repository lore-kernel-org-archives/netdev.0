From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 3/4] net: macb: Add support for jumbo frames
Date: Sat, 09 May 2015 17:43:25 -0400 (EDT)
Message-ID: <20150509.174325.2099472239572663193.davem@davemloft.net>
References: <1430931438-32592-1-git-send-email-harinik@xilinx.com>
	<1430931438-32592-3-git-send-email-harinik@xilinx.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbbEIVn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:43:28 -0400
In-Reply-To: <1430931438-32592-3-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harini Katakam <harini.katakam@xilinx.com>
Date: Wed, 6 May 2015 22:27:17 +0530

> Enable jumbo frame support for Zynq Ultrascale+ MPSoC.
> Update the NWCFG register and descriptor length masks accordingly.
> Jumbo max length register should be set according to support in SoC; it is
> set to 10240 for Zynq Ultrascale+ MPSoC.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
> Reviewed-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>

Applied.
