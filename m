From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SMSC: timeout reaches -1
Date: Fri, 20 Feb 2009 00:52:30 -0800 (PST)
Message-ID: <20090220.005230.197696135.davem@davemloft.net>
References: <49993E2D.4030103@gmail.com>
	<20090220.004114.239993457.davem@davemloft.net>
	<499E6F18.4080503@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752081AbZBTIws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:52:48 -0500
In-Reply-To: <499E6F18.4080503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 20 Feb 2009 09:51:36 +0100

> With a postfix decrement timeouts will reach -1 rather than 0, so
> the error path does not appear.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks.
