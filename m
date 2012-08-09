From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add new QCA alx ethernet driver
Date: Wed, 08 Aug 2012 23:11:20 -0700 (PDT)
Message-ID: <20120808.231120.1626915346739960080.davem@davemloft.net>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
	<6349D7A510622448B1BA0967850A8438013692CA@NASANEXD02D.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	xiong@qca.qualcomm.com, hao-ran.liu@canonical.com, joe@perches.com,
	rodrigue@qca.qualcomm.com
To: cjren@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab2HIGLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 02:11:23 -0400
In-Reply-To: <6349D7A510622448B1BA0967850A8438013692CA@NASANEXD02D.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Date: Thu, 9 Aug 2012 02:27:35 +0000

> The alx driver only supports two new nics(l1f/l2f) now.  It doesn't supersede atl1c driver.
> Atl1c driver still supports old nics.

There is no worse act than quoting a huge patch, only to provide two
lines of text.

Doing so is an enormous waste of resources, bandwith, and people's
time.  Everyone single person on the CC: list and the various mailing
lists had to consume this entire patch a second time, just to see
these two small lines of text you wanted to add.

Are you even aware of the ramifications of your actions at all?

If this lack of consideration extends to your actual coding as well, I
very much dread reviewing your work.

Please be incredibly more considerate and thoughtful with your email
etiquette, or I will just plain flat out ignore your patch submissions
entirely.
