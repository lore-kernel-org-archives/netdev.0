From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] smsc95xx: Add comments to the registers definition
Date: Wed, 12 Apr 2017 10:46:05 -0400 (EDT)
Message-ID: <20170412.104605.1126970886368700459.davem@davemloft.net>
References: <20170410135251.GC19820@lunn.ch>
        <20170411.221836.113758478587841074.davem@davemloft.net>
        <20170412092405.doyczwsqnzkizarz@SMX-2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, steve.glendinning@shawell.net,
        UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: martin@wetterwald.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754338AbdDLOqI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:46:08 -0400
In-Reply-To: <20170412092405.doyczwsqnzkizarz@SMX-2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Wetterwald <martin@wetterwald.eu>
Date: Wed, 12 Apr 2017 11:24:05 +0200

> This chip is used by a lot of embedded devices and also by the Raspberry
> Pi 1, 2 & 3 which were created to promote the study of computer
> sciences. Students wanting to learn kernel / network device driver
> programming through those devices can only rely on the Linux kernel
> driver source to make their own.
> 
> This commit adds a lot of comments to the registers definition to expand
> the register names.
> 
> Cc: Steve Glendinning <steve.glendinning@shawell.net>
> Cc: Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
> CC: David Miller <davem@davemloft.net>
> Signed-off-by: Martin Wetterwald <martin@wetterwald.eu>
> ---
> Changes in v3:
>  * Restore previous name for TX_CMD_B_CSUM_ENABLE

Please fix the GPIO numbers as indicated by Woojung Huh.
