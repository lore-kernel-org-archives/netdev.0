From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: include/linux/icmpv6: includecheck fix for
 icmpv6.h
Date: Wed, 12 Aug 2009 22:14:00 -0700 (PDT)
Message-ID: <20090812.221400.45400644.davem@davemloft.net>
References: <1249824438.2957.10.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jaswinder@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37322
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752027AbZHMFNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 01:13:50 -0400
In-Reply-To: <1249824438.2957.10.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date: Sun, 09 Aug 2009 18:57:18 +0530

> 
> fix the following 'make includecheck' warning:
> 
>   include/linux/icmpv6.h: linux/skbuff.h is included more than once.
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

Applied.
