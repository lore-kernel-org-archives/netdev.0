From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link
 down
Date: Wed, 01 Dec 2010 11:01:57 -0800 (PST)
Message-ID: <20101201.110157.246534994.davem@davemloft.net>
References: <AANLkTikvmRhkxB0WDUYeTj7qpsud0+qSHd+6Jj+k_eO=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40453
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753052Ab0LATBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:01:30 -0500
In-Reply-To: <AANLkTikvmRhkxB0WDUYeTj7qpsud0+qSHd+6Jj+k_eO=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Fri, 26 Nov 2010 10:06:58 -0800

> @@ -2663,8 +2663,7 @@ static int addrconf_ifdown(struct net_device
> *dev, int how)

Please fix your email client to not corrupt patches.

See Documentation/email-clients.txt
