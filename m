From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] netpoll: add IPv6 support
Date: Mon, 07 Jan 2013 20:54:48 -0800 (PST)
Message-ID: <20130107.205448.888117087367468727.davem@davemloft.net>
References: <1357543036-15492-1-git-send-email-amwang@redhat.com>
	<20130107.194621.1068055780988116658.davem@davemloft.net>
	<1357617351.3544.8.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab3AHEyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 23:54:49 -0500
In-Reply-To: <1357617351.3544.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 08 Jan 2013 11:55:51 +0800

> And AFAIK, udp6_csum_init() can't fit into any of these obj-y files in
> net/ipv6/.

So, uhm, like make a new one?
