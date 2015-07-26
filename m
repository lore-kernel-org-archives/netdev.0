From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] mlx4 driver fixes, July 22nd 2015
Date: Sun, 26 Jul 2015 16:30:49 -0700 (PDT)
Message-ID: <20150726.163049.217542583390603271.davem@davemloft.net>
References: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, talal@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033AbbGZXau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 19:30:50 -0400
In-Reply-To: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 22 Jul 2015 16:53:45 +0300

> Just few mlx4 fixes.. the fix related to propagating port state
> changes to VF should go to -stable of >= 3.11, all the rest just
> to 4.2-rc

Series applied and patch #2 queued up for -stable, thanks.
