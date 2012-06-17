From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues default
 8 queues
Date: Sun, 17 Jun 2012 01:08:17 -0700 (PDT)
Message-ID: <20120617.010817.1214320083280899562.davem@davemloft.net>
References: <1339688046.20038.3.camel@lb-tlvb-meravs.il.broadcom.com>
	<20120614.133649.794229745961162963.davem@davemloft.net>
	<1339916031.2486.0.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768Ab2FQIIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 04:08:25 -0400
In-Reply-To: <1339916031.2486.0.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If you're not going to read what I wrote, don't pretend that you did.
That really irritates me and makes me want to not review or apply your
patches.

I didn't say that there wasn't a problem.

I said that I don't want you to just blaze your own trail without
getting agreement and coordinating to adjust the other drivers in
unison as well.  I refuse to allow you to just change the default of
your driver and then well... maybe other drivers follow and maybe
others do not.  That hodge-podge inconsistent situation sucks for
users.

So now are you going to try again to explain the problem to me or
are you going to understand what my actual concern is?

Thanks.
