From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] [IPV6] ADDRCONF: Don't generate temporary
 address for ip6-ip6 interface.
Date: Sun, 13 Apr 2008 23:47:23 -0700 (PDT)
Message-ID: <20080413.234723.181065466.davem@davemloft.net>
References: <20080414.154706.62976282.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754317AbYDNGrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:47:21 -0400
In-Reply-To: <20080414.154706.62976282.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 14 Apr 2008 15:47:06 +0900 (JST)

> As far as I can remember, I was going to disable privacy extensions
> on all "tunnel" interfaces.  Disable it on ip6-ip6 interface as well.
> 
> Also, just remove ifdefs for SIT for simplicity.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Also applied, thank you.
