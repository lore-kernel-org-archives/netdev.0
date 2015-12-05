From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: constify netif_is_* helpers net_device
 param
Date: Sat, 05 Dec 2015 18:16:44 -0500 (EST)
Message-ID: <20151205.181644.505381810946685672.davem@davemloft.net>
References: <1449237691-17962-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbbLEXQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 18:16:45 -0500
In-Reply-To: <1449237691-17962-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  4 Dec 2015 15:01:31 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> As suggested by Eric, these helpers should have const dev param.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
