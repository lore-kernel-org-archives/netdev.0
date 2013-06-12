From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: udp4: move GSO functions to udp_offload
Date: Wed, 12 Jun 2013 00:48:47 -0700 (PDT)
Message-ID: <20130612.004847.18596600568882783.davem@davemloft.net>
References: <1370688963-32635-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51279 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424Ab3FLHss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 03:48:48 -0400
In-Reply-To: <1370688963-32635-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat,  8 Jun 2013 12:56:03 +0200

> Similarly to TCP offloading and UDPv6 offloading, move all related
> UDPv4 functions to udp_offload.c to make things more explicit. Also,
> by this, we can make those functions static.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
