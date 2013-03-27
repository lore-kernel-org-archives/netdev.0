From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch: add missing u64 in psched_ratecfg_precompute()
Date: Wed, 27 Mar 2013 14:11:13 -0400 (EDT)
Message-ID: <20130327.141113.1783472428071007326.davem@davemloft.net>
References: <10857839.dV42UeFzbk@tuxracer.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: popovich_sergei@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58932 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab3C0SLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 14:11:15 -0400
In-Reply-To: <10857839.dV42UeFzbk@tuxracer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>
Date: Wed, 27 Mar 2013 17:41:59 +0200

> It seems that commit
> 
> commit 292f1c7ff6cc10516076ceeea45ed11833bb71c7
> Author: Jiri Pirko <jiri@resnulli.us>
> Date:   Tue Feb 12 00:12:03 2013 +0000
> 
>     sch: make htb_rate_cfg and functions around that generic
> 
> adds little regression.
 ...
> Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>

Applied.
