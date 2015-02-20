From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] be2net patch-set
Date: Fri, 20 Feb 2015 14:08:30 -0500 (EST)
Message-ID: <20150220.140830.1456778523374137048.davem@davemloft.net>
References: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbbBTTId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 14:08:33 -0500
In-Reply-To: <1424054028-23659-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Date: Mon, 16 Feb 2015 08:03:44 +0530

> This patch set contains a few code refactoring changes to make it easy to
> support new TX WRB formats in future ASICs. Please consider applying it to
> net-next tree.
> 
> Patch 1: Refactors chip specific code to setup tx wrb into a separate routine.
> Patch 2: Refactors tx enqueue function to remove a bit of duplicate code and
> 	 improves wrb setup steps.
> Patch 3: Minor refactoring in tx compl to limit CQE accesses to 1 routine.
> Patch 4: Adds a few inline functions.

Series applied, thanks.
