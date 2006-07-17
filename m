From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] WAN: Converted synclink drivers to use
 netif_carrier_*()
Date: Sun, 16 Jul 2006 19:00:42 -0700 (PDT)
Message-ID: <20060716.190042.85415873.davem@davemloft.net>
References: <m3veq3suve.fsf@defiant.localdomain>
	<m3zmf9love.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61139
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751617AbWGQCA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 22:00:26 -0400
To: khc@pm.waw.pl
In-Reply-To: <m3zmf9love.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sun, 16 Jul 2006 14:23:49 +0200

> WAN: Converted synclink drivers to use netif_carrier_*() instead
> of hdlc_set_carrier().
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

Also applied, thanks for fixing this up Krzysztof.
