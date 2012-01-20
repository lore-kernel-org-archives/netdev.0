From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Fri, 20 Jan 2012 13:50:28 -0500 (EST)
Message-ID: <20120120.135028.1359677274445012541.davem@davemloft.net>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, tgraf@infradead.org,
	stephen.hemminger@vyatta.com, hagen@jauu.net,
	eric.dumazet@gmail.com, seiji.aguchi@hds.com
To: satoru.moriya@hds.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816Ab2ATSwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 13:52:54 -0500
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 20 Jan 2012 13:07:02 -0500

> Sometimes network packets are dropped for some reason. In enterprise
> systems which require strict RAS functionality, we must know the
> reason why it happened and explain it to our customers even if using
> TCP.

You were given an alternative way to trace these kinds of events,
and you have yet to give us a solid reason why that cannot work
for you.

I am not applying these patches, sorry.
