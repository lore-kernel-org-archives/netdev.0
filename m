From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] net: sh_eth: add the value of tsu to the
 SH7757's GETHER
Date: Thu, 16 Feb 2012 17:08:45 -0500 (EST)
Message-ID: <20120216.170845.406136620478964761.davem@davemloft.net>
References: <4F3C7E0B.1080001@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753981Ab2BPWIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 17:08:51 -0500
In-Reply-To: <4F3C7E0B.1080001@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Thu, 16 Feb 2012 12:54:51 +0900

> The SH7757's GETHER has TSU registers. So, this patch adds the value
> of ".tsu = 1" in the sh_eth_cpu_data.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
