From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv4: disable BH when changing ip local port range
Date: Wed, 04 Nov 2015 21:29:38 -0500 (EST)
Message-ID: <20151104.212938.1009303289561138145.davem@davemloft.net>
References: <1446589977-31225-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030403AbbKEC3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 21:29:42 -0500
In-Reply-To: <1446589977-31225-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  3 Nov 2015 14:32:57 -0800

> This fixes the following lockdep warning:
 ...
> Fixes: b8f1a55639e6 ("udp: Add function to make source port for UDP tunnels")
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
