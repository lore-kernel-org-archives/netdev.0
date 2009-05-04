From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] macb: Add support of the netpoll API
Date: Mon, 04 May 2009 11:08:51 -0700 (PDT)
Message-ID: <20090504.110851.247698525.davem@davemloft.net>
References: <20090421.015414.259541482.davem@davemloft.net>
	<1241438084-17350-1-git-send-email-haavard.skinnemoen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, michael@free-electrons.com,
	netdev@vger.kernel.org
To: haavard.skinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754824AbZEDSI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 14:08:56 -0400
In-Reply-To: <1241438084-17350-1-git-send-email-haavard.skinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Mon,  4 May 2009 13:54:44 +0200

> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> 
> With this patch in place, I'm successfully able to use the netconsole
> mechanism with the Calao USB-A9263 board, which uses the AT91SAM9263
> CPU, which in terms of Ethernet controller is supported by the macb
> driver.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> [haavard.skinnemoen@atmel.com: disable_irq() -> local_irq_save()]
> [haavard.skinnemoen@atmel.com: convert to net_device_ops]
> Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>

Applied to net-next-2.6, thanks!
