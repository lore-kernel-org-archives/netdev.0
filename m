From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipheth: Add support for iPad 2 and iPad 3
Date: Mon, 02 Jun 2014 16:12:17 -0700 (PDT)
Message-ID: <20140602.161217.1136496149550873922.davem@davemloft.net>
References: <1401445020-14027-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kristian.evensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485AbaFBXMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 19:12:18 -0400
In-Reply-To: <1401445020-14027-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>
Date: Fri, 30 May 2014 12:17:00 +0200

> From: Kristian Evensen <kristian.evensen@gmail.com>
> 
> Each iPad model has a different product id, this patch adds support for iPad 2
> (pid 0x12a2) and iPad 3 (pid 0x12a6). Note that iPad 2 must be jailbroken and a
> third-party app must be used for tethering to work. On iPad 3, tethering works
> out of the box (assuming your ISP is nice).
> 
> Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>

These are just device ID additions, so I applied this to 'net'.

Thanks.
