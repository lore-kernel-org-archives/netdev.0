From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] [RESEND] ethtool: Add hw-switch-offload to
 netdev_features_strings.
Date: Fri, 20 Feb 2015 16:38:02 -0500 (EST)
Message-ID: <20150220.163802.997481138018179498.davem@davemloft.net>
References: <1424460898-4045-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767AbbBTViE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 16:38:04 -0500
In-Reply-To: <1424460898-4045-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Fri, 20 Feb 2015 21:34:58 +0200

> commit aafb3e98b279 (netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature 
> flag for switch device offloads) add a new feature without adding it to 
> netdev_features_strings array; this patch fixes this.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
