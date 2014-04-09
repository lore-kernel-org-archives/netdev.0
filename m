From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: Add default vlan for dual
 emac case also
Date: Wed, 09 Apr 2014 14:56:24 -0400 (EDT)
Message-ID: <20140409.145624.1000792872429500740.davem@davemloft.net>
References: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933143AbaDIS40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 14:56:26 -0400
In-Reply-To: <1397023480-4181-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 9 Apr 2014 11:34:40 +0530

> Dual EMAC works with VLAN segregation of the ports, so default vlan needs
> to be added in dual EMAC case else default vlan will be tagged for all
> egress packets and vlan unaware switches/servers will drop packets
> from the EVM.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
