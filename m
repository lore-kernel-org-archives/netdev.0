From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Sat, 20 Sep 2008 13:19:15 -0700 (PDT)
Message-ID: <20080920.131915.143583562.davem@davemloft.net>
References: <1221925413.1343.132.camel@localhost.localdomain>
	<20080920.130325.56429707.davem@davemloft.net>
	<1221941809.1343.229.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: dwalker@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37018
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbYITUT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 16:19:28 -0400
In-Reply-To: <1221941809.1343.229.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@mvista.com>
Date: Sat, 20 Sep 2008 13:16:49 -0700

> On Sat, 2008-09-20 at 13:03 -0700, David Miller wrote:
> 
> > On UP we get a single queue, which the layer needs anyways.
> > It just always queues to the one queue.
> > 
> > Unlike Andrew's, your review comments have been completely and utterly
> > useless, as well as a total waste of my time.
> 
> If you don't want your code reviewed, _don't send it_

Sounds like a plan.

