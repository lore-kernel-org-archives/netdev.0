From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 3/5] sock_diag: allow to dump bpf filters
Date: Thu, 25 Apr 2013 05:00:08 -0400 (EDT)
Message-ID: <20130425.050008.2129680886418162075.davem@davemloft.net>
References: <1366818756-4234-4-git-send-email-nicolas.dichtel@6wind.com>
	<1366820565.8964.78.camel@edumazet-glaptop>
	<5178EB2C.6070709@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332Ab3DYJAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 05:00:10 -0400
In-Reply-To: <5178EB2C.6070709@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 25 Apr 2013 10:37:00 +0200

> Maybe I'm wrong, but I was thinking that this module is used for debug
> purpose.

No, it's a normal tool.
