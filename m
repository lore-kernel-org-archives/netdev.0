From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove rt_cache_rebuild_count
Date: Mon, 30 Jul 2012 14:56:54 -0700 (PDT)
Message-ID: <20120730.145654.256366317443584870.davem@davemloft.net>
References: <1343668469.21269.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004Ab2G3V4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 17:56:54 -0400
In-Reply-To: <1343668469.21269.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Jul 2012 19:14:29 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> After IP route cache removal, rt_cache_rebuild_count is no longer
> used.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
