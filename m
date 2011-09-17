From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/3] bna: Set Ring Param Fix
Date: Sat, 17 Sep 2011 00:48:14 -0400 (EDT)
Message-ID: <20110917.004814.2209713364192737974.davem@davemloft.net>
References: <1316221608-21392-1-git-send-email-rmody@brocade.com>
	<1316221608-21392-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	gkaraje@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45152 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1IQEtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 00:49:17 -0400
In-Reply-To: <1316221608-21392-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Fri, 16 Sep 2011 18:06:47 -0700

> When Rx queue size is changed, queues are torn down and setup with the new queue
> size. During this operation, clear promiscuous mode and restore the original
> VLAN filter.
> 
> Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied.
