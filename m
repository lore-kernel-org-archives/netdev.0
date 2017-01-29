From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: ethernet: aquantia: remove another
 redundant err check
Date: Sun, 29 Jan 2017 18:24:21 -0500 (EST)
Message-ID: <20170129.182421.2254139449919836161.davem@davemloft.net>
References: <20170127150025.18886-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Pavel.Belous@aquantia.com, Alexander.Loktionov@aquantia.com,
        Dmitry.Bezrukov@aquantia.com, vomlehn@texas.net,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170127150025.18886-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 27 Jan 2017 15:00:25 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The check on err < 0 is redundant and can be removed. Detected
> by CoverityScan, CID#1398318 ("Logically Dead Code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
