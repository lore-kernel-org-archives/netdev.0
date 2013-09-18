From: David Miller <davem@davemloft.net>
Subject: Re: pull request net: batman-adv 2013-09-18
Date: Wed, 18 Sep 2013 12:23:20 -0400 (EDT)
Message-ID: <20130918.122320.1303866480594733298.davem@davemloft.net>
References: <1379485658-2317-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651Ab3IRQXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:23:22 -0400
In-Reply-To: <1379485658-2317-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 18 Sep 2013 08:27:37 +0200

> this is a very small (but important) fix intended for net/linux-3.{11,12} (since
> 3.12-rc1 is out I guess this patch needs to be enqueued for stable in order to
> reach 3.11?)
> 
> This change fixes a regression introduced in 3.11 that prevents the Bridge Loop
> Avoidance component from correctly operate on VLANs.

Pulled and queued up for -stable.
