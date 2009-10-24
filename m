From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] xfrm6_tunnel: RCU conversion
Date: Sat, 24 Oct 2009 06:09:20 -0700 (PDT)
Message-ID: <20091024.060920.258223911.davem@davemloft.net>
References: <4AE28047.1020904@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39864
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753292AbZJXNI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:08:57 -0400
In-Reply-To: <4AE28047.1020904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nice work Eric, I applied all of your RCU conversions to
net-next-2.6, thanks!

Applying: ipv6 sit: RCU conversion phase I
Applying: ipv6 sit: RCU conversion phase II
Applying: xfrm6_tunnel: RCU conversion
Applying: ipip: convert hash tables locking to RCU
Applying: ip6tnl: convert hash tables locking to RCU
Applying: gre: convert hash tables locking to RCU
