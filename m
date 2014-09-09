From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Cleanup of unncessary check.
Date: Tue, 09 Sep 2014 11:32:22 -0700 (PDT)
Message-ID: <20140909.113222.1785356613258694402.davem@davemloft.net>
References: <1409998088-12938-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaIIScX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:32:23 -0400
In-Reply-To: <1409998088-12938-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Sat,  6 Sep 2014 13:08:08 +0300

> This patch removes an unncessary check in the br_afspec() method of
> br_netlink.c.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
