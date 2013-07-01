From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] alx fixes/improvements
Date: Mon, 01 Jul 2013 13:18:48 -0700 (PDT)
Message-ID: <20130701.131848.823812279465894769.davem@davemloft.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755201Ab3GAUSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:18:49 -0400
In-Reply-To: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Sat, 29 Jun 2013 19:23:12 +0200

> Unfortunately WoL is broken and the system always wakes up
> immediately, and the code also looks rather odd to me. As I
> can't seem to fix it (with admittedly mostly random hacking)
> I'm removing it, sorry. Having the system come back from
> sleep immediately doesn't seem very useful though, I'm sure
> it can be added back by somebody more interested than me.

More work seems to be needed on patch #8, so I applied just
#1 to #7 to net-next.

Thanks.
