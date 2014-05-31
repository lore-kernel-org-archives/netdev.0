From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: fec: use pinctrl PM helpers
Date: Fri, 30 May 2014 17:03:52 -0700 (PDT)
Message-ID: <20140530.170352.2196404366015569028.davem@davemloft.net>
References: <1401177068-6206-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b20596@freescale.com, R65073@freescale.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934548AbaEaADx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:03:53 -0400
In-Reply-To: <1401177068-6206-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 27 May 2014 15:51:08 +0800

> when system suspend, need to set pins to low power state to
> save IO power consumption, there are three states of pinctrl:
> "default", "idle" and "sleep". Currently enet supports default
> and sleep state.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied to net-next, thanks.
