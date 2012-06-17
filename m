From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues default
 8 queues
Date: Sun, 17 Jun 2012 02:00:58 -0700 (PDT)
Message-ID: <20120617.020058.2281757592609638666.davem@davemloft.net>
References: <1339916031.2486.0.camel@lb-tlvb-eilong.il.broadcom.com>
	<20120617.010817.1214320083280899562.davem@davemloft.net>
	<1339922036.2486.1.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792Ab2FQJA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 05:00:58 -0400
In-Reply-To: <1339922036.2486.1.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Sun, 17 Jun 2012 11:33:56 +0300

> drivers now, it does not sound like a good path - so I was asking if you
> can consider a kernel parameter as acceptable path. To be clear, I'm
> asking if adding the default for all multi-queue drivers in the form of
> a kernel parameter is a good path to explore.

If it's the default, there's no need for a kernel command line
parameter.  Those suck, just pick a good default.
