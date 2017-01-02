From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: add missing call to genlmsg_end
Date: Sun, 01 Jan 2017 22:01:19 -0500 (EST)
Message-ID: <20170101.220119.1826844137337345474.davem@davemloft.net>
References: <20161231201157.10800-1-wr0112358@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: wr0112358@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdABDBY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 22:01:24 -0500
In-Reply-To: <20161231201157.10800-1-wr0112358@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Reiter Wolfgang <wr0112358@gmail.com>
Date: Sat, 31 Dec 2016 21:11:57 +0100

> Update nlmsg_len field with genlmsg_end to enable userspace processing
> using nlmsg_next helper. Also adds error handling.
> 
> Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>

Applied and queued up for -stable, thanks.
