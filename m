From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Fri, 30 Jun 2006 14:16:58 -0700 (PDT)
Message-ID: <20060630.141658.34759102.davem@davemloft.net>
References: <adawtazgawi.fsf@cisco.com>
	<20060629.124628.88476747.davem@davemloft.net>
	<ada3bdmfjug.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25741
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932609AbWF3VRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:17:01 -0400
To: rdreier@cisco.com
In-Reply-To: <ada3bdmfjug.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 30 Jun 2006 13:51:19 -0700

> And I can't think of a single other example of a case where we
> refused to merge a driver, not because of any issues with the driver
> code, but because we don't like the hardware it drives and think
> that people shouldn't be able to use the HW with Linux.  And it
> makes me sad that we're doing that here.

The TOE folks have tried to submit their hooks and drivers
on several occaisions, and we've rejected it every time.

I definitely don't want the iWARP stuff to go in until we
have a long good discussion about this.  And you have a good
week long opportunity to do so as I'm about to go on vacation
until next Friday :-)
