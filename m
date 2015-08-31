From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip-tunnel: Use API to access tunnel metadata
 options.
Date: Mon, 31 Aug 2015 12:29:11 -0700 (PDT)
Message-ID: <20150831.122911.1625667885956647191.davem@davemloft.net>
References: <1440983378-2107-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158AbbHaT3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:29:12 -0400
In-Reply-To: <1440983378-2107-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Sun, 30 Aug 2015 18:09:38 -0700

> Currently tun-info options pointer is used in few cases to
> pass options around. But tunnel options can be accessed using
> ip_tunnel_info_opts() API without using the pointer. Following
> patch removes the redundant pointer and consistently make use
> of API.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks.
