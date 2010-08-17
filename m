From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/7] enic: updates to version 1.4.1.2
Date: Tue, 17 Aug 2010 02:35:15 -0700 (PDT)
Message-ID: <20100817.023515.183029530.davem@davemloft.net>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34304
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932160Ab0HQJe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:34:58 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Tue, 10 Aug 2010 21:54:50 -0700

> This patch series implements the following enic driver updates:
> 
> 01/7 - Add set mac address
> 02/7 - Add support for firmware management device
> 03/7 - Add new firmware devcmds
> 04/7 - Use offsetof macro in vic tlv length calculation
> 05/7 - Clean up: remove enic_dev_stats_clear
> 06/7 - Check if rq/wq buf not NULL before freeing them
> 07/7 - Mark intr_timer in vnic_enet_config as deprecated
> 
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>
> Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
> Signed-off-by: Vasanthy Kolluri<vkolluri@cisco.com>

All applied, thank you.
