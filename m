From: David Miller <davem@davemloft.net>
Subject: Re: [patch] tg3: missing break statement in
 tg3_get_5720_nvram_info()
Date: Thu, 10 Jan 2013 23:00:43 -0800 (PST)
Message-ID: <20130110.230043.734496375588063177.davem@davemloft.net>
References: <20130111065733.GG13207@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, mcarlson@broadcom.com,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456Ab3AKHAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 02:00:50 -0500
In-Reply-To: <20130111065733.GG13207@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 11 Jan 2013 09:57:33 +0300

> There is a missing break statement so FLASH_5762_EEPROM_HD gets treated
> like FLASH_5762_EEPROM_LD.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
