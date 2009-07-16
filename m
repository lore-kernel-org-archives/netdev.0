From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] gianfar: Remove unused DECLARE_MAC_BUF
Date: Thu, 16 Jul 2009 06:16:27 -0700 (PDT)
Message-ID: <20090716.061627.193734311.davem@davemloft.net>
References: <1247734285-20648-1-git-send-email-klto@zhaw.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, galak@kernel.crashing.org,
	netdev@vger.kernel.org
To: klto@zhaw.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755993AbZGPNQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 09:16:23 -0400
In-Reply-To: <1247734285-20648-1-git-send-email-klto@zhaw.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <klto@zhaw.ch>
Date: Thu, 16 Jul 2009 10:51:25 +0200

> Is not needed anymore because of the %pM printk conversion specifier.
> 
> Signed-off-by: Tobias Klauser <klto@zhaw.ch>

I already applied the same fix from Johannes yesterday.
