From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [NET-NEXT PATCH] net: macb: Change capability mask for jumbo
 support
Date: Thu, 23 Jul 2015 14:42:31 +0200
Message-ID: <20150723124231.GS2853@piout.net>
References: <1437646465-6462-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre@atmel.com, davem@davemloft.net, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	boris.brezillon@free-electrons.com, harinikatakamlinux@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, harinik@xilinx.com, punnaia@xilinx.com,
	michals@xilinx.com
To: Harini Katakam <harini.katakam@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:56757 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751025AbbGWMmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 08:42:35 -0400
Content-Disposition: inline
In-Reply-To: <1437646465-6462-1-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/07/2015 at 15:44:25 +0530, Harini Katakam wrote :
> JUMBO and NO_GIGABIT_HALF have the same capability masks.
> Change one of them.
> 
> Signed-off-by: Harini Katakam <harinik@xilinx.com>
Acked-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>


-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
