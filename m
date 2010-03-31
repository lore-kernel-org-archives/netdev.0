From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 (TAKE 2)] ipv6: Use __fls() instead of
 fls() in __ipv6_addr_diff().
Date: Tue, 30 Mar 2010 23:40:43 -0700 (PDT)
Message-ID: <20100330.234043.258204728.davem@davemloft.net>
References: <201003291600.o2TG05VI032167@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932798Ab0CaGkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:40:42 -0400
In-Reply-To: <201003291600.o2TG05VI032167@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 30 Mar 2010 01:00:05 +0900

> Because we have ensured that the argument is non-zero,
> it is better to use __fls() and generate better code.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
