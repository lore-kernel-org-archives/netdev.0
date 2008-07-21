From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use kcalloc in netdev_queue alloc
Date: Mon, 21 Jul 2008 13:28:56 -0700 (PDT)
Message-ID: <20080721.132856.137306094.davem@davemloft.net>
References: <20080721111933.4cdad67f@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751207AbYGUU24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:28:56 -0400
In-Reply-To: <20080721111933.4cdad67f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jul 2008 11:19:33 -0700

> Minor nit, use size_t for allocation size and kcalloc to allocate
> an array. Probably makes no actual code difference.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good, applied.

Thanks Stephen.
