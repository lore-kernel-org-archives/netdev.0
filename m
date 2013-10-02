From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tg3: use phylib when robo switch is in use
Date: Wed, 02 Oct 2013 15:42:39 -0400 (EDT)
Message-ID: <20131002.154239.159934637654326231.davem@davemloft.net>
References: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
	<1380402928-11480-3-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nsujir@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
To: hauke@hauke-m.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933Ab3JBTml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 15:42:41 -0400
In-Reply-To: <1380402928-11480-3-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Sat, 28 Sep 2013 23:15:28 +0200

> When a switch is connected as a PHY to the MAC driven by tg3, use
> phylib and provide the phy address to tg3 from the sprom.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Applied to net-next.
