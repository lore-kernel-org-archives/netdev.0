From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: ethernet: aquantia: remove redundant
 err check
Date: Sun, 29 Jan 2017 18:24:15 -0500 (EST)
Message-ID: <20170129.182415.414553797234358867.davem@davemloft.net>
References: <20170127144346.18565-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Pavel.Belous@aquantia.com, Alexander.Loktionov@aquantia.com,
        Dmitry.Bezrukov@aquantia.com, vomlehn@texas.net,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdA2XYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 18:24:17 -0500
In-Reply-To: <20170127144346.18565-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Fri, 27 Jan 2017 14:43:46 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The check on err < 0 is redundant and can be removed. Detected
> by CoverityScan, CID#1398321 ("Logically Dead Code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
