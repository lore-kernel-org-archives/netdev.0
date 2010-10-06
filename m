From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] bonding: print information about
 speed and duplex seen by the driver
Date: Wed, 06 Oct 2010 14:28:00 -0700 (PDT)
Message-ID: <20101006.142800.28821715.davem@davemloft.net>
References: <4ca4b873.iZ0Dea7Y1OFcVmf8%ole@ans.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33925
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933147Ab0JFV1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 17:27:39 -0400
In-Reply-To: <4ca4b873.iZ0Dea7Y1OFcVmf8%ole@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Piotr Oledzki <ole@ans.pl>
Date: Thu, 30 Sep 2010 18:18:59 +0200

>>From d4fb10933bb88f2bf410b0abe42f151c13e3df85 Mon Sep 17 00:00:00 2001
> From: Krzysztof Piotr Oledzki <ole@ans.pl>
> Date: Thu, 30 Sep 2010 17:05:19 +0200
> Subject: bonding: print information about speed and duplex seen by the driver
> 
> before:
>  bonding: bond0: link status definitely up for interface eth5
>  bonding: bond0: link status definitely up for interface eth0
> 
> after:
>  bonding: bond0: link status definitely up for interface eth5, 100 Mbps full duplex.
>  bonding: bond0: link status definitely up for interface eth0, 100 Mbps full duplex.
> 
> 
> Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Applied.
