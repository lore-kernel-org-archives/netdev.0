From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bridge: fix NULL pointer deref of
 br_port_get_rcu
Date: Mon, 16 Sep 2013 00:55:00 -0400 (EDT)
Message-ID: <20130916.005500.495876508046881031.davem@davemloft.net>
References: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	vyasevic@redhat.com, zhiguohong@tencent.com
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab3IPEzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 00:55:01 -0400
In-Reply-To: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>
Date: Sat, 14 Sep 2013 22:42:26 +0800

> Hong Zhiguo (2):
>   bridge: use br_port_get_rtnl within rtnl lock
>   bridge: fix NULL pointer deref of br_port_get_rcu

Both applied and queued up for -stable, thanks.
