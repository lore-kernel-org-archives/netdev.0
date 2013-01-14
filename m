From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-01-14
Date: Sun, 13 Jan 2013 20:39:40 -0500 (EST)
Message-ID: <20130113.203940.971636104315231474.davem@davemloft.net>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755300Ab3ANBjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 20:39:41 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Mon, 14 Jan 2013 09:41:05 +1000

> this is our first changeset intended for net-next/linux-3.9.
> In this batch you have mostly code refactoring, style adjustments and output
> beautifications.
> The only new 'behaviours' are:
> - prevent the TT component from learning multicast mac addresses as they are not
>   really handled (yet)
> - initialise own lockdep class for each hash table in order to avoid false
>   positive from lockdep
...
>   git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

Pulled, thanks.
