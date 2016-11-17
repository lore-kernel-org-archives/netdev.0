From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 7/7] net: ethernet: ti: cpsw: fix fixed-link phy
 probe deferral
Date: Thu, 17 Nov 2016 12:04:16 -0500 (EST)
Message-ID: <20161117.120416.1443476818715961812.davem@davemloft.net>
References: <1479400804-9847-1-git-send-email-johan@kernel.org>
        <1479400804-9847-8-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479400804-9847-8-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Thu, 17 Nov 2016 17:40:04 +0100

> Make sure to propagate errors from of_phy_register_fixed_link() which
> can fail with -EPROBE_DEFER.
> 
> Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link
> PHY")
> Signed-off-by: Johan Hovold <johan@kernel.org>

Johan, when you update a patch within a series you must post the
entire series freshly to the lists, cover posting and all.

Thank you.
