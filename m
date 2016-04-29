From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] net: ethernet: enc28j60: small
 improvements
Date: Fri, 29 Apr 2016 16:23:17 -0400 (EDT)
Message-ID: <20160429.162317.643995306941650386.davem@davemloft.net>
References: <1461873975-6368-1-git-send-email-mhei@heimpold.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jic23@kernel.org, afd@ti.com, broonie@kernel.org,
	netdev@vger.kernel.org
To: mhei@heimpold.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbcD2UXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:23:19 -0400
In-Reply-To: <1461873975-6368-1-git-send-email-mhei@heimpold.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Heimpold <mhei@heimpold.de>
Date: Thu, 28 Apr 2016 22:06:13 +0200

> This series of two patches adds the following improvements to the driver:
> 
> 1) Rework the central SPI read function so that it is compatible with
>    SPI masters which only support half duplex transfers.
> 
> 2) Add a device tree binding for the driver.
> 
> Changelog:
> 
> v3: * renamed and improved binding documentation as
>       suggested by Rob Herring
> 
> v2: * took care of Arnd Bergmann's review comments
>       - allow to specify MAC address via DT
>       - unconditionally define DT id table
>     * increased the driver version minor number
>     * driver author's email address bounces, removed from address list
> 
> v1: * Initial submission

Series applied, thanks.
