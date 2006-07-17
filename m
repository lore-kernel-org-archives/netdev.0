From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: Added missing netif_dormant_off() to generic HDLC
Date: Sun, 16 Jul 2006 18:58:59 -0700 (PDT)
Message-ID: <20060716.185859.106266169.davem@davemloft.net>
References: <m3veq3suve.fsf@defiant.localdomain>
	<m33bd1n3qn.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14480
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751339AbWGQB6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 21:58:43 -0400
To: khc@pm.waw.pl
In-Reply-To: <m33bd1n3qn.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sun, 16 Jul 2006 14:17:20 +0200

> WAN: Fixed a problem with PPP/raw HDLC/X.25 protocols not doing
> netif_dormant_off() at startup.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

Applied, thanks.
