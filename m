From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-01-27
Date: Sun, 27 Jan 2013 19:11:40 -0500 (EST)
Message-ID: <20130127.191140.655904034749695176.davem@davemloft.net>
References: <1359315839-24136-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039Ab3A1ALl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 19:11:41 -0500
In-Reply-To: <1359315839-24136-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Sun, 27 Jan 2013 20:43:56 +0100

> This is a small patchset intended for net/linux-3.8.
> Here there are three small patches from Matthias Schiffer aimed to fix some
> memory problems in the recently introduced D.A.T. component. One of them is
> fixing an skb memleak, one is fixing the ARP filter routine by preventing DAT to
> parse not useful messages (so reducing the amount of memory used by the local
> cache) and one fixing again the ARP filter routine by preventing DAT to
> overwrite correct entries with bogus ones in the local cache.
> 
> Please pull or let me know if there is any problem.

Pulled, thanks Antonio.
