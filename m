From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Mon, 25 Apr 2016 22:50:44 -0400 (EDT)
Message-ID: <20160425.225044.885414475689272721.davem@davemloft.net>
References: <571E72AA.4030100@cumulusnetworks.com>
	<20160425.164227.1599148827995063295.davem@davemloft.net>
	<571E943C.9010504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mmanning@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbcDZCur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 22:50:47 -0400
In-Reply-To: <571E943C.9010504@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 25 Apr 2016 16:03:40 -0600

> Rather than focusing on my mistakes, why not see the commitment on
> following through with this change?

I do not question the amount of time and effort invested.

I question whether the change was truly ready yet, and my
conclusion right now is that it is not ready for 4.6.0-final

So I reverted instead of waiting for the other shoe to drop.

Thanks.
