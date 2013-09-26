From: David Miller <davem@redhat.com>
Subject: Re: rx_dropped count for USB ethernet interfaces
Date: Thu, 26 Sep 2013 13:21:25 -0400 (EDT)
Message-ID: <20130926.132125.1343558938307288175.davem@redhat.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B735B@saturn3.aculab.com>
	<20130925.144640.1661224048195310923.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B735E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753827Ab3IZRVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 13:21:30 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B735E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 26 Sep 2013 10:32:24 +0100

> It isn't exactly useful behaviour though.

In your opinion.

We have tracepoints for people who want more fine grained drops
in these kinds of situations.

Also, the behavior of this statistic has existed for more than a
decade so changing it is really not in the cards.  Therefore any
discussion about what would have been the best samentic to choose from
the beginning is moot.
