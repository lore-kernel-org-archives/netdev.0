From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] Mellanox driver fixes June 4th, 2013
Date: Tue, 04 Jun 2013 12:58:46 -0700 (PDT)
Message-ID: <20130604.125846.1042759714389642426.davem@davemloft.net>
References: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab3FDT6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 15:58:47 -0400
In-Reply-To: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue,  4 Jun 2013 18:13:25 +0300

> Hi Dave,
> 
> This short series has one bugfix to the adaptive moderation code
> and three SRIOV fixes. 
> 
> The patch from Jack Morgenstein follows the suggestion made over this thread
> https://patchwork.kernel.org/patch/2569591/ by Ben H. to simply return -EPROBE_DEFER 
> when a VF relalizes they can't do their probe now. Other two patches from me treat
> issues in the VF and PF driver relating to handling VF MAC addresses.
> 
> Series done against net tree, commit 01cb71d2d "net_sched: restore "overhead xxx" handling"

Applied, thanks.
