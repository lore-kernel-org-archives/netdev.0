From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ipv6 ip6_tunnel: eliminate unused recursion
 field from ip6_tnl{}.
Date: Wed, 10 Mar 2010 07:34:15 -0800 (PST)
Message-ID: <20100310.073415.140466860.davem@davemloft.net>
References: <201003100247.o2A2lqaX001898@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53854
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756690Ab0CJPdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 10:33:55 -0500
In-Reply-To: <201003100247.o2A2lqaX001898@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 10 Mar 2010 11:47:52 +0900

> Commit a43912ab19... ("tunnel: eliminate recursion field") eliminated
> use of recursion field from tunnel structures, but its definition
> still exists in ip6_tnl{}.
> 
> Let's remove that unused field.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
