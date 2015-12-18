From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipip: ioctl: Remove superfluous IP-TTL handling.
Date: Fri, 18 Dec 2015 16:08:12 -0500 (EST)
Message-ID: <20151218.160812.1544150617286452401.davem@davemloft.net>
References: <1450399599-7528-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965294AbbLRVIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 16:08:13 -0500
In-Reply-To: <1450399599-7528-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Thu, 17 Dec 2015 16:46:39 -0800

> IP-TTL case is already handled in ip_tunnel_ioctl() API.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks Pravin.
