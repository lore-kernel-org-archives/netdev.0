From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: Remove write permission from phy_type
 attribute
Date: Wed, 19 Jun 2013 22:19:11 -0700 (PDT)
Message-ID: <20130619.221911.589157489583077294.davem@davemloft.net>
References: <1371573940.1956.19.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab3FTFTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 01:19:12 -0400
In-Reply-To: <1371573940.1956.19.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 18 Jun 2013 17:45:40 +0100

> Driver probe currently results in:
> 
> WARNING: at drivers/base/core.c:576 device_create_file+0x57/0x7e()
> Attribute phy_type: write permission without 'store'
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
