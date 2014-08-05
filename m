From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/12] dsa: support for Broadcom
 Starfighter 2
Date: Tue, 05 Aug 2014 15:38:44 -0700 (PDT)
Message-ID: <20140805.153844.68135520292921100.davem@davemloft.net>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740AbaHEWir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 18:38:47 -0400
In-Reply-To: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue,  5 Aug 2014 15:31:34 -0700

> Hi all,
> 
> This patch series adds support for the Broadcom Starfighter 2 (Roboswitch
> successor) using the existing DSA infrastructure. This integrated switch
> is heavily used in Set Top Box, Cable gateways and DSL gateways products
> from Broadcom, and to a larger extend the new ARM-based Wi-Fi routers although
> slightly differently.
> 
> The biggest changes from v1 of this patch series are:
> 
> - use the new fixed PHY helpers
> - improved the switch driver with more complete features (interrupts,
>   (RG)MII configuration, memory arrays power down/up, port disabling/enable
>   VLAN separation
> 
> Future work will focus on bringing the upstream driver in feature parity with
> the current downstream driver, including:
> 
> - adding Wake-on-LAN support to the switch
> - adding suspend/resume callbacks for S2/S3 Power Management modes
> - extending the switch register interface to cover BCM5310X SoCs

Sorry Florian, the merge window just openned up so I have to stop accepting
new features.

Please repost this after I open the net-next tree up again, thanks a lot.
