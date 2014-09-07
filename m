From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Sun, 07 Sep 2014 16:19:20 -0700 (PDT)
Message-ID: <20140907.161920.1260393276111898261.davem@davemloft.net>
References: <20140904.223648.559995846094457545.davem@davemloft.net>
	<20140905134758.GB1256@oracle.com>
	<20140906210253.GA5710@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.stevens@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbaIGXTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:19:21 -0400
In-Reply-To: <20140906210253.GA5710@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat, 6 Sep 2014 17:02:53 -0400

> So what (if any) is the outstanding question about wmb() at this 
> point?

I don't think there is any, thanks.
