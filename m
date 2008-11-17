From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use %pF for /proc/net/ptype
Date: Sun, 16 Nov 2008 19:50:47 -0800 (PST)
Message-ID: <20081116.195047.148811305.davem@davemloft.net>
References: <20081114111004.GA3321@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755487AbYKQDur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 22:50:47 -0500
In-Reply-To: <20081114111004.GA3321@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 14 Nov 2008 14:10:04 +0300

> Technically, patch changes format for modules, but I think nobody cares.
> 
> 	-86dd          :ipv6:ipv6_rcv+0x0
> 	+86dd          ipv6_rcv+0x0/0x400 [ipv6]
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Indeed, this is a good patch, applied.

Thanks Alexey.
