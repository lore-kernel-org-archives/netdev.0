From: "Vasanthy Kolluri (vkolluri)" <vkolluri@cisco.com>
Subject: RE: [net-next-2.6 PATCH 0/5] enic: updates to version 2.1.1.6
Date: Mon, 7 Feb 2011 11:32:08 -0800
Message-ID: <212AA327A3557741A058E787E06188730549170E@xmb-sjc-219.amer.cisco.com>
References: <20110205021618.8510.34816.stgit@savbu-pc100.cisco.com> <20110206.111856.39183676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:19400 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754711Ab1BGTcL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 14:32:11 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20110206.111856.39183676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The below patch series should apply clean on top of another enic patch
"enic: Decouple mac address registration and deregistration from port
profile set operation" submitted earlier by roprabhu@cisco.com. Just
want to ensure that it's not missed.

Please let me know if there is still a need to re-spin.

Thanks
Vasanthy



-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of David Miller
Sent: Sunday, February 06, 2011 11:19 AM
To: Vasanthy Kolluri (vkolluri)
Cc: netdev@vger.kernel.org
Subject: Re: [net-next-2.6 PATCH 0/5] enic: updates to version 2.1.1.6

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Fri, 04 Feb 2011 18:17:00 -0800

> The following series implements enic driver updates:
> 
> 1/5 - Clean up: Organize devcmd wrapper routines
> 2/5 - Bug Fix: Fix return values of enic_add/del_station_addr routines
> 3/5 - Bug Fix: Reorder firmware devcmds - CMD_INIT and
CMD_IG_VLAN_REWRITE_MODE
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
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
