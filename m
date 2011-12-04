From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, fixed phy: make BUSID configurable
Date: Sun, 04 Dec 2011 13:23:21 -0500 (EST)
Message-ID: <20111204.132321.9566486322084069.davem@davemloft.net>
References: <1322991444-20626-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbordug@ru.mvista.com, akpm@osdl.org,
	jeff@garzik.org, wd@denx.de
To: hs@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab1LDSXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:23:41 -0500
In-Reply-To: <1322991444-20626-1-git-send-email-hs@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Schocher <hs@denx.de>
Date: Sun,  4 Dec 2011 10:37:24 +0100

> Signed-off-by: Heiko Schocher <hs@denx.de>

Give me a break.

You can't submit a change like this with essentially an
empty commit message.

Why in the world does this ever need to be configurable?
Are there alternative (and much better) ways to deal with
whatever problem this patch solves?

You've presented no information about why you need to make this
change, and more importantly why no viable alternatives exist
to solve your problem.
