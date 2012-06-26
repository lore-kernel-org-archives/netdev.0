From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/sh-eth: Add support selecting MII function for
 SH7734 and R8A7740
Date: Mon, 25 Jun 2012 23:55:00 -0700 (PDT)
Message-ID: <20120625.235500.1547357191552248108.davem@davemloft.net>
References: <1340681654-2159-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nobuhiro.iwamatsu.yj@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581Ab2FZGzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 02:55:01 -0400
In-Reply-To: <1340681654-2159-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Date: Tue, 26 Jun 2012 12:34:14 +0900

> Ethernet IP of SH7734 and R8A7740 has selecting MII register.
> The user needs to change a value according to MII to be used.
> This adds the function to change the value of this register.
> 
> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Applied to net-next.
