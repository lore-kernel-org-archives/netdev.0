From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] mlx4 core fixes
Date: Mon, 16 Jan 2017 15:08:47 -0500 (EST)
Message-ID: <20170116.150847.2285234602909157132.davem@davemloft.net>
References: <1484584299-3950-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com,
        jackm@dev.mellanox.co.il
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdAPUQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 15:16:59 -0500
In-Reply-To: <1484584299-3950-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 16 Jan 2017 18:31:36 +0200

> This patchset contains bug fixes from Jack to the mlx4 Core driver.
> 
> Patch 1 solves a race in the flow of CQ free.
> Patch 2 moves some qp context flags update to the correct qp transition.
> Patch 3 eliminates warnings from the path of SRQ_LIMIT that flood the message log,
> and keeps them only in the path of SRQ_CATAS_ERROR.
> 
> Series generated against net commit:
> 1a717fcf8bbe Merge tag 'mac80211-for-davem-2017-01-13' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211

Series applied, thanks.
