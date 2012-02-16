From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] net: sh_eth: change the condition of
 initialization
Date: Thu, 16 Feb 2012 17:08:51 -0500 (EST)
Message-ID: <20120216.170851.1507805839397401532.davem@davemloft.net>
References: <4F3C7E10.3060905@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981Ab2BPWI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 17:08:56 -0500
In-Reply-To: <4F3C7E10.3060905@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Thu, 16 Feb 2012 12:54:56 +0900

> The SH7757 has 2 Fast Ethernet and 2 Gigabit Ethernet, and the first
> Gigabit channel needs the initialization. So, this patch adds the
> parameter of "needs_init", and if the sh_eth_plat_data is set it
> to 1, the driver will initialize the channel.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
