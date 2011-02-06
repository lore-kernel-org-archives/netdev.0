From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/5] enic: updates to version 2.1.1.6
Date: Sun, 06 Feb 2011 11:18:56 -0800 (PST)
Message-ID: <20110206.111856.39183676.davem@davemloft.net>
References: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53070
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753396Ab1BFTSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Feb 2011 14:18:25 -0500
In-Reply-To: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Fri, 04 Feb 2011 18:17:00 -0800

> The following series implements enic driver updates:
> 
> 1/5 - Clean up: Organize devcmd wrapper routines
> 2/5 - Bug Fix: Fix return values of enic_add/del_station_addr routines
> 3/5 - Bug Fix: Reorder firmware devcmds - CMD_INIT and CMD_IG_VLAN_REWRITE_MODE
> 4/5 - Clean up: Remove support for an older version of hardware
> 5/5 - Update MAINTAINERS
> 
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

These patches do not apply cleanly to current net-next-2.6, please
respin them.

Thanks.
