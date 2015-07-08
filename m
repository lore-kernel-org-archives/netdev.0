From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] sfc: compat for lack of VADAPTOR_SET_MAC in
 adaptor_firmware <= 4.1.1.1023
Date: Wed, 08 Jul 2015 16:07:47 -0700 (PDT)
Message-ID: <20150708.160747.125026767371942405.davem@davemloft.net>
References: <559BAB66.1080905@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbGHXHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:07:48 -0400
In-Reply-To: <559BAB66.1080905@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Tue, 7 Jul 2015 11:35:18 +0100

> This patch series resolves an incompatibility with legacy
> firmware due to the lack of MC_CMD_VADAPTOR_SET_MAC in
> adaptor_firmware <= 4.1.1.1023
> 
> Unless this patch series is applied there will be a compatibility
> issue between the driver and Solarflare adapters running older
> firmware. 
> 
> Tested with and without CONFIG_SFC_SRIOV

Series applied, thanks.
