From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 17:58:19 -0700 (PDT)
Message-ID: <20100416.175819.20524881.davem@davemloft.net>
References: <20100416.155340.256882855.davem@davemloft.net>
	<20100416.155707.66748057.davem@davemloft.net>
	<i2s65634d661004161722hece6f9d4naf528c37b63fffbc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43316
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758533Ab0DQA6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 20:58:17 -0400
In-Reply-To: <i2s65634d661004161722hece6f9d4naf528c37b63fffbc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 16 Apr 2010 17:22:49 -0700

> Ugh, vmalloc.h must be sneaking in through some other header file for
> me :-(  Sorry about that.  Do you need me to respin the patch?

No, I took care of it and am about to push things out to net-next-2.6
on kernel.org
