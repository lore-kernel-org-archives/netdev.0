From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] mlx5 fixes to 4.8-rc6
Date: Mon, 19 Sep 2016 22:10:46 -0400 (EDT)
Message-ID: <20160919.221046.1211702186242722683.davem@davemloft.net>
References: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, hadarh@mellanox.com,
        amirva@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbcITCKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 22:10:50 -0400
In-Reply-To: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 18 Sep 2016 18:20:26 +0300

> This series series has a fix from Roi to memory corruption bug in 
> the bulk flow counters code and two late and hopefully last fixes 
> from me to the new eswitch offloads code.
> 
> Series done over net commit 37dd348 "bna: fix crash in bnad_get_strings()"

Series applied, thanks.
