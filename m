From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: macb: use module_platform_driver_probe()
Date: Tue, 05 Mar 2013 23:59:03 -0500 (EST)
Message-ID: <20130305.235903.451411479737990346.davem@davemloft.net>
References: <005101ce194b$04f4d980$0ede8c80$%han@samsung.com>
	<005201ce194b$318a6c80$949f4580$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab3CFE7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:59:05 -0500
In-Reply-To: <005201ce194b$318a6c80$949f4580$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Tue, 05 Mar 2013 11:43:18 +0900

> This patch uses module_platform_driver_probe() macro which makes
> the code smaller and simpler.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
