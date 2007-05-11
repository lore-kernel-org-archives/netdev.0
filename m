From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/6 v2] phylib: add the ICPlus IP175C PHY driver
Date: Fri, 11 May 2007 16:59:17 -0400
Message-ID: <4644D925.9060004@garzik.org>
References: <20070510151611.1a8a0af8.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42404 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761421AbXEKU7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:59:19 -0400
In-Reply-To: <20070510151611.1a8a0af8.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kim Phillips wrote:
> From: Michael Barkowski <michael.barkowski@freescale.com>
> 
> The ICPlus IP175C sports a 100Mbit/s 4-port switch in addition
> to a dedicated 100Mbit/s WAN port.
> 
> Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> --- 
> v2: adjusted to read PHY reset register before performing prescribed delay,
> to account for bus delays; udelay -> mdelay; plus fixed codingstyle issues.
> 
>  drivers/net/phy/Kconfig  |    6 ++
>  drivers/net/phy/Makefile |    1 +
>  drivers/net/phy/icplus.c |  134 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 141 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/phy/icplus.c

ACK but failed to apply


