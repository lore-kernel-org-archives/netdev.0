From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cpsw: ethtool: add support for nway reset
Date: Tue, 29 Nov 2016 19:41:58 -0500 (EST)
Message-ID: <20161129.194158.1482957574907674651.davem@davemloft.net>
References: <1480326472-5849-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        grygorii.strashko@ti.com, mugunthanvnm@ti.com
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbcK3AmA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:42:00 -0500
In-Reply-To: <1480326472-5849-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yegorslists@googlemail.com
Date: Mon, 28 Nov 2016 10:47:52 +0100

> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> This patch adds support for ethtool's '-r' command. Restarting
> N-WAY negotiation can be useful to activate newly changed EEE
> settings etc.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

This doesn't apply cleanly to net-next.
