From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] at86rf230: fix lockdep splats
Date: Thu, 13 Mar 2014 15:44:45 -0400 (EDT)
Message-ID: <20140313.154445.445146359636607166.davem@davemloft.net>
References: <1394608884-3644-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55698 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763AbaCMTor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:44:47 -0400
In-Reply-To: <1394608884-3644-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Wed, 12 Mar 2014 08:21:24 +0100

> This patch fix a lockdep in the at86rf230 driver, otherwise we get:
 ...
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>

Applied, thank you.
