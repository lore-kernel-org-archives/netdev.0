From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 net-next 1/2] bonding: display xmit_hash_policy for
 non-dynamic-tlb mode
Date: Mon, 06 Oct 2014 17:13:36 -0400 (EDT)
Message-ID: <20141006.171336.433768353135221925.davem@davemloft.net>
References: <1412469884-27308-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbaJFVNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:13:39 -0400
In-Reply-To: <1412469884-27308-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat,  4 Oct 2014 17:44:44 -0700

> It's a trivial fix to display xmit_hash_policy for this new TLB mode
> since it uses transmit-hash-poilicy as part of bonding-master info
> (/proc/net/bonding/<bonding-interface).
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
