From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: at91_ether: use module_platform_driver_probe()
Date: Tue, 05 Mar 2013 23:58:56 -0500 (EST)
Message-ID: <20130305.235856.1316062048897710304.davem@davemloft.net>
References: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab3CFE65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:58:57 -0500
In-Reply-To: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 05 Mar 2013 11:42:03 +0900

> This patch uses module_platform_driver_probe() macro which makes
> the code smaller and simpler.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
