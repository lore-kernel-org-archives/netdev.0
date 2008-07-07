From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Sun, 06 Jul 2008 23:44:33 -0700 (PDT)
Message-ID: <20080706.234433.172895242.davem@davemloft.net>
References: <20080706213427.406e8f29@infradead.org>
	<20080706.214915.255106355.davem@davemloft.net>
	<20080706215711.135a8524@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbYGGGoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 02:44:34 -0400
In-Reply-To: <20080706215711.135a8524@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Sun, 6 Jul 2008 21:57:11 -0700

> one option is that I carry this patch in the WARN tree (which I plan to
> submit for -next tomorrow)

It's going to be a conflict field day with net-next-2.6 especially
with some changes I have coming in there soon, otherwise I'd say
that yes that would be the way to do.

We're going to have to do this in multiple stages somehow.

