From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/6] be2net: fixes
Date: Wed, 03 Aug 2011 03:27:24 -0700 (PDT)
Message-ID: <20110803.032724.2002152463981614514.davem@redhat.com>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792Ab1HCK11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 06:27:27 -0400
In-Reply-To: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Wed, 3 Aug 2011 11:27:40 +0530

> Pls apply.
> 
> Sathya Perla (6):
>   be2net: remove wrong and unnecessary calls to netif_carrier_off()
>   be2net: no need to query link status
>   be2net: non-member vlan pkts not received in promiscous mode
>   be2net: use RX_FILTER cmd to program multicast addresses
>   be2net: add support for flashing Teranetics PHY firmware
>   be2net: drop pkts that do not belong to the port

Queued up for net-next, thanks.
