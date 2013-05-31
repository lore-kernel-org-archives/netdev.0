From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/6] net/core, bonding: dev_uc_sync fixes,
 bonding update
Date: Fri, 31 May 2013 16:58:01 -0700 (PDT)
Message-ID: <20130531.165801.1061633523224111641.davem@davemloft.net>
References: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755070Ab3EaX6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 19:58:02 -0400
In-Reply-To: <1370037451-29466-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 31 May 2013 14:57:25 -0700

> 	This patch set includes 6 patches: four fixes to the dev_mc_sync /
> dev_mc_unsync system; and two patches to bonding, one to utilize the sync
> / unsync functions, and another minor fix.

I've merged patches #1 to #4 to 'net' and added the tested-by and reviewed-by
tags that the previous series obtained, since these patches are unchanged
in v2.

I'll apply v5 and v6 when I next merge net into net-next.

Thanks.
