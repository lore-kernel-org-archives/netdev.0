From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: Add support for the OpenCores 10/100 Mbps
 Ethernet MAC.
Date: Fri, 27 Mar 2009 00:17:03 -0700 (PDT)
Message-ID: <20090327.001703.116902601.davem@davemloft.net>
References: <20090326080959.GA23013@avionic-design.de>
	<1238062584-12685-1-git-send-email-thierry.reding@avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thierry.reding@avionic-design.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751359AbZC0HRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:17:15 -0400
In-Reply-To: <1238062584-12685-1-git-send-email-thierry.reding@avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Reding <thierry.reding@avionic-design.de>
Date: Thu, 26 Mar 2009 11:16:24 +0100

> This patch adds a platform device driver that supports the OpenCores 10/100
> Mbps Ethernet MAC.
> 
> The driver expects three resources: one IORESOURCE_MEM resource defines the
> memory region for the core's memory-mapped registers while a second
> IORESOURCE_MEM resource defines the network packet buffer space. The third
> resource, of type IORESOURCE_IRQ, associates an interrupt with the driver.
> 
> Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks.
