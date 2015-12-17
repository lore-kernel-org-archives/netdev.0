From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] ipv6: allow routes to be configured with
 expire values
Date: Thu, 17 Dec 2015 15:09:03 -0500 (EST)
Message-ID: <20151217.150903.1977974325959462390.davem@davemloft.net>
References: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754824AbbLQUJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:09:05 -0500
In-Reply-To: <3b977653c7ade52e180d754eb660ec66af212e94.1450259411.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 16 Dec 2015 17:50:11 +0800

> Add the support for adding expire value to routes,  requested by
> Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
> wants it too.
> 
> implement it by adding the new RTNETLINK attribute RTA_EXPIRES.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
