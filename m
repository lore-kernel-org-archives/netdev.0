From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net/core, bonding: dev_uc_sync fixes,
 bonding update
Date: Fri, 31 May 2013 01:31:55 -0700 (PDT)
Message-ID: <20130531.013155.25881045915195152.davem@davemloft.net>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791Ab3EaIb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 04:31:56 -0400
In-Reply-To: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Thu, 30 May 2013 17:55:38 -0700

> 	This patch set includes 6 patches: four fixes to the dev_mc_sync /
> dev_mc_unsync system; and two patches to bonding, one to utilize the sync
> / unsync functions, and another minor fix related to MAC address handling.

These look like fixes that should go into net, why target net-next?

In any event, I'll let Vlad review this before applying anywhere.

Thanks.
