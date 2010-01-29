From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: maintain namespace isolation between vlan and
 real device
Date: Thu, 28 Jan 2010 21:33:44 -0800 (PST)
Message-ID: <20100128.213344.226776729.davem@davemloft.net>
References: <201001271104.20607.arnd@arndb.de>
	<201001271105.15733.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, kaber@trash.net, mst@redhat.com,
	herbert@gondor.apana.org.au, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55104
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750950Ab0A2Fdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 00:33:32 -0500
In-Reply-To: <201001271105.15733.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 27 Jan 2010 11:05:15 +0100

> + * skb_dev_set -- assign a buffer to a new device

My english is terrible, but I think this should be
"assign a new device to a buffer".

If you agree, please fix this up when you resubmit patches #1 and #2
along with the fix you already plan to make to patch #3.

Thanks!
