From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: Use __fls() instead of fls() in
 __ipv6_addr_diff().
Date: Mon, 29 Mar 2010 11:33:02 -0700 (PDT)
Message-ID: <20100329.113302.144148264.davem@davemloft.net>
References: <201003260801.o2Q8134t023352@94.43.138.210.xn.2iij.net>
	<4BB0CBF3.805@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43635
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441Ab0C2SdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 14:33:01 -0400
In-Reply-To: <4BB0CBF3.805@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 30 Mar 2010 00:49:07 +0900

> Sorry, I withdraw this because this is incorrect;
> __fls() returns fls() - 1.

Ok.
