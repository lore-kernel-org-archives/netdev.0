From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Thu, 07 Jan 2010 23:47:37 -0800 (PST)
Message-ID: <20100107.234737.174030302.davem@davemloft.net>
References: <1262914750.10429.88.camel@Joe-Laptop.home>
	<alpine.LFD.2.00.1001080143250.13474@eddie.linux-mips.org>
	<BD79186B4FD85F4B8E60E381CAEE19090208961F@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: macro@linux-mips.org, joe@perches.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750974Ab0AHHrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 02:47:31 -0500
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090208961F@mi8nycmail19.Mi8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Thu, 7 Jan 2010 21:11:34 -0500

> Can you please un-apply both this patch and the one for skfddi.c?

I can't "unapply" them.  They have been pushed out to my
net-next-2.6 tree and thus are irreversably a part of the
permanent record.

Submit fixes instead, if indeed fixes are even necessary.
