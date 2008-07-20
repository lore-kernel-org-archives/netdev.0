From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 3/4] net: Use standard structures for generic
 socket address structures.
Date: Sat, 19 Jul 2008 22:41:48 -0700 (PDT)
Message-ID: <20080719.224148.190321820.davem@davemloft.net>
References: <20080720.142134.58233586.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751780AbYGTFls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 01:41:48 -0400
In-Reply-To: <20080720.142134.58233586.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sun, 20 Jul 2008 14:21:34 +0900 (JST)

> Use sockaddr_storage{} for generic socket address storage
> and ensures proper alignment.
> Use sockaddr{} for pointers to omit several casts.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
