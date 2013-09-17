From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnels: raddr and laddr are inverted in nl msg
Date: Mon, 16 Sep 2013 21:36:54 -0400 (EDT)
Message-ID: <20130916.213654.633956568361199680.davem@davemloft.net>
References: <1379323875-3794-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhi.ding@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525Ab3IQBgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:36:55 -0400
In-Reply-To: <1379323875-3794-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 16 Sep 2013 11:31:15 +0200

> From: Ding Zhi <zhi.ding@6wind.com>
> 
> IFLA_IPTUN_LOCAL and IFLA_IPTUN_REMOTE were inverted.
> 
> Introduced by c075b13098b3 (ip6tnl: advertise tunnel param via rtnl).
> 
> Signed-off-by: Ding Zhi <zhi.ding@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
