From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Bug Fixes for SFC driver
Date: Tue, 21 Jan 2014 14:47:21 -0800 (PST)
Message-ID: <20140121.144721.1436515776352406432.davem@davemloft.net>
References: <52D98860.4020402@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaAUWrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 17:47:22 -0500
In-Reply-To: <52D98860.4020402@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 17 Jan 2014 19:45:36 +0000

> I am taking over the upstream patch submission work for the 
> sfc driver from Ben Hutchings.
> 
> These patches are bug fixes to the sfc driver involving 
> replacement of the PORT RESET MC command and fixing transposed 
> ptp_{under,over}size_sync_window_statistics
> 
> The PORT_RESET bug fix is needed for all versions supporting EF10
> i.e all versions including and after 3.12.

Series applied, thanks.
