From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/9] net/mlx4_en: Fix wrong indentation
Date: Thu, 08 Sep 2016 13:35:50 -0700 (PDT)
Message-ID: <20160908.133550.573024313413474065.davem@davemloft.net>
References: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
        <1473324721-5206-3-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, kamalh@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758786AbcIHUfv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 16:35:51 -0400
In-Reply-To: <1473324721-5206-3-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu,  8 Sep 2016 11:51:54 +0300

> From: Kamal Heib <kamalh@mellanox.com>
> 
> Use tabs instead of spaces before if statement, no functional change.
> 
> Fixes: e7c1c2c46201 ("mlx4_en: Added self diagnostics test implementation")
> Signed-off-by: Kamal Heib <kamalh@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Cleanups like this are not bug fixes, please don't put things like this
into changes targetting 'net'.
