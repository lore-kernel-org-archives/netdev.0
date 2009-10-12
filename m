From: David Miller <davem@davemloft.net>
Subject: Re: [RESED PATCH net-next-2.6 2/3] ipv6 sit: Fix 6rd relay address.
Date: Mon, 12 Oct 2009 02:08:22 -0700 (PDT)
Message-ID: <20091012.020822.109698176.davem@davemloft.net>
References: <4AD1E14D.6030903@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755245AbZJLJI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 05:08:27 -0400
In-Reply-To: <4AD1E14D.6030903@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 11 Oct 2009 22:44:45 +0900

> ipv6 sit: Fix 6rd relay address.
> 
> Relay's address should be extracted from real IPv6 address
> instead of configured prefix.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
