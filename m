From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sh-eth: Check return value of sh_eth_reset when
 chip reset fail
Date: Mon, 25 Jun 2012 23:55:07 -0700 (PDT)
Message-ID: <20120625.235507.1153823662243777987.davem@davemloft.net>
References: <1340681712-2212-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florian@openwrt.org
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581Ab2FZGzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 02:55:08 -0400
In-Reply-To: <1340681712-2212-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Tue, 26 Jun 2012 12:35:12 +0900

> The sh_eth_reset function resets chip, but this performs nothing when failed.
> This changes sh_eth_reset return an error, when this failed in reset.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Applied to net-next.
