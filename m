From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: dp83848: Fix sysfs naming collision warning
Date: Thu, 18 Feb 2016 15:53:27 -0500 (EST)
Message-ID: <20160218.155327.1798360624333332424.davem@davemloft.net>
References: <1455754200-4593-1-git-send-email-afd@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: afd@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455754200-4593-1-git-send-email-afd@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Andrew F. Davis" <afd@ti.com>
Date: Wed, 17 Feb 2016 18:10:00 -0600

> Files in sysfs are created using the name from the phy_driver struct,
> when two names are the same we may get a duplicate filename warning,
> fix this.
> 
> Reported-by: kernel test robot <ying.huang@linux.intel.com>
> Signed-off-by: Andrew F. Davis <afd@ti.com>

Applied, thanks.
