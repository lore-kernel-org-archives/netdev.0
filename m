From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net: broadcom: fix FIXED_PHY dependencies
Date: Tue, 16 Dec 2014 00:57:41 -0500 (EST)
Message-ID: <20141216.005741.633306754952668057.davem@davemloft.net>
References: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbaLPF5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 00:57:46 -0500
In-Reply-To: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 15 Dec 2014 09:57:12 -0800

> This patch series removes the bogus "select FIXED_PHY if FOO=y" that
> I have been using in GENET, SYSTEMPORT and the SF2 DSA switch
> driver.

Series applied, thanks Florian.
