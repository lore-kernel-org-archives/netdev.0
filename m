From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/11] tg3: 5719, VLAN, and EEE bugfixes
Date: Tue, 25 Jan 2011 22:27:34 -0800 (PST)
Message-ID: <20110125.222734.189693738.davem@davemloft.net>
References: <1296007137-23146-1-git-send-email-mcarlson@broadcom.com>
	<20110125.193859.193720518.davem@davemloft.net>
	<1296022477.2633.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, andy@greyhouse.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750932Ab1AZG07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 01:26:59 -0500
In-Reply-To: <1296022477.2633.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Jan 2011 07:14:37 +0100

> I tested the vlan patch on my machine, and it solves the problem I had
> with linux-2.6
> 
> I believe this particular patch should be net-2.6 material, not
> net-next-2.6

Agreed.

> (There is a small rejected hunk)

Matt, if you would send me a net-2.6 backport with your blessing
I'd appreciate it.
