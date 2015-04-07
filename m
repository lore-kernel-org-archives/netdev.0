From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] netns: enhance netlink interface for
 nsid
Date: Tue, 07 Apr 2015 17:30:10 -0400 (EDT)
Message-ID: <20150407.173010.509729473608323973.davem@davemloft.net>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
	<1428400314-4472-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbbDGVaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 17:30:11 -0400
In-Reply-To: <1428400314-4472-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  7 Apr 2015 11:51:51 +0200

> The first patch is a small cleanup. The second patch implements notifications
> for netns id events. And the last one allows to dump existing netns id from
> userland.
> 
> iproute2 patches are available, I can send them on demand.
> 
> v2: drop the first patch (the fix is now in net-next)

Series applied, thanks.
