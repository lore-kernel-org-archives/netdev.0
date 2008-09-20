From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [PATCH 2/2]: softirq: Add support for triggering softirq work
	on softirqs.
Date: Sat, 20 Sep 2008 13:16:49 -0700
Message-ID: <1221941809.1343.229.camel@localhost.localdomain>
References: <20080919.234832.127229997.davem@davemloft.net>
	 <1221925413.1343.132.camel@localhost.localdomain>
	 <20080920.130325.56429707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homer.mvista.com ([63.81.120.158]:48524 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbYITUQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 16:16:55 -0400
In-Reply-To: <20080920.130325.56429707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-09-20 at 13:03 -0700, David Miller wrote:

> On UP we get a single queue, which the layer needs anyways.
> It just always queues to the one queue.
> 
> Unlike Andrew's, your review comments have been completely and utterly
> useless, as well as a total waste of my time.

If you don't want your code reviewed, _don't send it_ .. Don't start an
argument with me cause you don't want deal with reviewers..

Daniel

