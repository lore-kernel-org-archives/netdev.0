From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/9] net/mlx4_en: Add branch prediction hints in RX
 data-path
Date: Thu, 08 Sep 2016 13:35:18 -0700 (PDT)
Message-ID: <20160908.133518.682601752079656938.davem@davemloft.net>
References: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
        <1473324721-5206-2-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39954 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758786AbcIHUfW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 16:35:22 -0400
In-Reply-To: <1473324721-5206-2-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu,  8 Sep 2016 11:51:53 +0300

> Add likely/unlikely hints to improve branch predictions
> in the RX data-path.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

This is absolutely not appropriate for 'net'.  This is not a bug
fix, it is a feature/enhancement.
