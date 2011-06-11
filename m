From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Enable NETIF_F_TSO6 for VLAN
 traffic for BE
Date: Sat, 11 Jun 2011 15:58:56 -0700 (PDT)
Message-ID: <20110611.155856.1488502138217599598.davem@davemloft.net>
References: <5c1f3a19-f30f-40b4-8715-86348d7917c5@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: padmanabh.ratnakar@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab1FKW7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 18:59:00 -0400
In-Reply-To: <5c1f3a19-f30f-40b4-8715-86348d7917c5@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@Emulex.Com>
Date: Fri, 10 Jun 2011 16:31:48 +0530

> NETIF_F_TSO6 for VLAN packets was not enabled for BE adapters.
> Enabling it.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>

Applied, thanks.
