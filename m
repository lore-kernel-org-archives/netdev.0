From: David Miller <davem@davemloft.net>
Subject: Re: pull request for net: batman-adv 2013-05-17
Date: Fri, 17 May 2013 01:41:40 -0700 (PDT)
Message-ID: <20130517.014140.2125848646591726751.davem@davemloft.net>
References: <1368778211-2142-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754284Ab3EQIll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:41:41 -0400
In-Reply-To: <1368778211-2142-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Fri, 17 May 2013 10:10:10 +0200

> here you have one fix intended for net/linux-3.10.
> This patch is fixing a global fault protection that can be triggered on module
> removal due to the double invocation of call_rcu() in chain.
> 
> While fixing, the patch is also adding some kernel doc to the changed functions.
> Consider queueing this patch to -stable.

Pulled, thanks.
