From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 7/7] net: ethernet: ti: cpsw: fix fixed-link phy
 probe deferral
Date: Fri, 18 Nov 2016 13:48:05 -0500 (EST)
Message-ID: <20161118.134805.1178638605544036871.davem@davemloft.net>
References: <1479400804-9847-8-git-send-email-johan@kernel.org>
        <20161117.120416.1443476818715961812.davem@davemloft.net>
        <20161117171920.GD10490@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: johan@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161117171920.GD10490@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johan Hovold <johan@kernel.org>
Date: Thu, 17 Nov 2016 18:19:20 +0100

> On Thu, Nov 17, 2016 at 12:04:16PM -0500, David Miller wrote:
>> From: Johan Hovold <johan@kernel.org>
>> Date: Thu, 17 Nov 2016 17:40:04 +0100
>> 
>> > Make sure to propagate errors from of_phy_register_fixed_link() which
>> > can fail with -EPROBE_DEFER.
>> > 
>> > Fixes: 1f71e8c96fc6 ("drivers: net: cpsw: Add support for fixed-link
>> > PHY")
>> > Signed-off-by: Johan Hovold <johan@kernel.org>
>> 
>> Johan, when you update a patch within a series you must post the
>> entire series freshly to the lists, cover posting and all.
> 
> I'm quite sure that is exactly what I did. Did you only get this last
> patch out of the seven?

I ended up getting it delayed, thanks.
