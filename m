From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] packet_diag: enhance advertised infos
Date: Mon, 29 Apr 2013 13:22:56 -0400 (EDT)
Message-ID: <20130429.132256.154437723285872941.davem@davemloft.net>
References: <1366903930.8964.154.camel@edumazet-glaptop>
	<1366908834-21606-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757018Ab3D2RXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 13:23:02 -0400
In-Reply-To: <1366908834-21606-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 25 Apr 2013 18:53:51 +0200

> The goal of this patchset is to be able to get all infos exported via the
> /proc/net/packet and also beeing able to get filter associated to af_packet
> sockets.
> 
> As usual, the patch against iproute2 will be sent once the patches are included
> and net-next merged. I can send it on demand.

Series applied, thanks Nicolas.
