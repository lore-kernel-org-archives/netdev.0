From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4vf: Initialize mdio_addr before using it
Date: Tue, 13 Jan 2015 16:32:12 -0500 (EST)
Message-ID: <20150113.163212.1132191636990094854.davem@davemloft.net>
References: <1421080576-30885-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbbAMVcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:32:20 -0500
In-Reply-To: <1421080576-30885-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon, 12 Jan 2015 22:06:16 +0530

> In commit 5ad24def21b205a8 ("cxgb4vf: Fix ethtool get_settings for VF driver")
> mdio_addr of port_info structure was used unininitialzed. Fixing it.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
