From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: reconfigure resources for kdump crash
 kernel
Date: Sun, 04 Jan 2015 22:24:08 -0500 (EST)
Message-ID: <20150104.222408.778804325620128434.davem@davemloft.net>
References: <1420293944-7614-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbbAEDYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 22:24:09 -0500
In-Reply-To: <1420293944-7614-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Sat,  3 Jan 2015 19:35:44 +0530

> When running in kdump kernel, reduce number of resources used by the driver.
> This will enable NIC to operate in low memory kdump kernel environment.
> 
> Also change the driver version to .83
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied, thank you.
