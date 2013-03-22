From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: Add XGMII phy interface type
Date: Fri, 22 Mar 2013 10:19:00 -0400 (EDT)
Message-ID: <20130322.101900.1947638393872492900.davem@davemloft.net>
References: <E1UJ1fR-0004hy-AI@swissweb.swissdisk.com>
	<20130322.101259.1120794715082991238.davem@davemloft.net>
	<5BDCE647-67A3-423B-AB9C-8C50CC0B6C02@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.c@servergy.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: benmcollins13@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5BDCE647-67A3-423B-AB9C-8C50CC0B6C02@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Collins <benmcollins13@gmail.com>
Date: Fri, 22 Mar 2013 10:17:35 -0400

> On Mar 22, 2013, at 10:12 AM, David Miller <davem@davemloft.net> wrote:
> 
>> From: Ben Collins <ben.c@servergy.com>
>> Date: Mon, 18 Mar 2013 19:53:42 -0400
>> 
>>> Used by systems based on certain Freescale SoCs (specifically the
>>> Servergy CTS-1000 system).
>>> 
>>> Signed-off-by: Ben Collins <ben.c@servergy.com>
>> 
>> You can resubmit this patch when you submit a driver upstream that
>> uses it, so we can see what the use case looks like.
> 
> That patch is getting sent soon. It's starting out in staging. Should I Cc you on that?

Why don't you wait until the driver is good enough for drivers/net proper?
