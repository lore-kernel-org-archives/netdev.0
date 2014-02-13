From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 00/10] Support for the Broadcom GENET driver
Date: Thu, 13 Feb 2014 18:38:06 -0500 (EST)
Message-ID: <20140213.183806.278183709549075615.davem@davemloft.net>
References: <1392334222-1089-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	cernekee@gmail.com, mark.rutland@arm.com, romieu@fr.zoreil.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaBMXiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:38:10 -0500
In-Reply-To: <1392334222-1089-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 13 Feb 2014 15:30:12 -0800

> This patchset adds support for the Broadcom GENET Gigabit Ethernet MAC
> controller. This controller is found on the Broadcom BCM7xxx Set Top Box
> System-on-a-chips.
> 
> Changes since v3:
> - fixed Kconfig dependency on FIXED_PHY
> 
> Changes since v2:
> - dropped the patch that adds an "internal" phy-mode

Looks better, series applied, thanks.
