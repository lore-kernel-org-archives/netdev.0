From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arc: trivial: Replace comma with a semicolon
Date: Wed, 25 May 2016 22:13:36 -0700 (PDT)
Message-ID: <20160525.221336.1615492413751852117.davem@davemloft.net>
References: <1464216005-6327-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wxt@rock-chips.com, heiko@sntech.de
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcEZFNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 01:13:43 -0400
In-Reply-To: <1464216005-6327-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Thu, 26 May 2016 00:40:05 +0200

> Fix a typo in the driver, replace comma with a semicolon at the end
> of statement. While using comma is a legal C here and probably does
> not even generate compiler warning, it was unlikely the intention.
> 
> Signed-off-by: Marek Vasut <marex@denx.de>

Applied.
