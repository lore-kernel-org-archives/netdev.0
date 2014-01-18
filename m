From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bluetooth: remove direct compilation of 6lowpan_iphc.c
Date: Fri, 17 Jan 2014 19:10:53 -0800 (PST)
Message-ID: <20140117.191053.2165670259882490823.davem@davemloft.net>
References: <1389986964-5177-1-git-send-email-swarren@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, marcel@holtmann.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com, netdev@vger.kernel.org,
	jukka.rissanen@linux.intel.com, swarren@nvidia.com
To: swarren@wwwdotorg.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1389986964-5177-1-git-send-email-swarren@wwwdotorg.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Warren <swarren@wwwdotorg.org>
Date: Fri, 17 Jan 2014 12:29:24 -0700

> From: Stephen Warren <swarren@nvidia.com>
> 
> It's now built as a separate utility module, and enabling BT selects
> that module in Kconfig. This fixes:
 ...
> (this change probably simply wasn't "git add"d to a53d34c3465b)
> 
> Fixes: a53d34c3465b ("net: move 6lowpan compression code to separate module")
> Fixes: 18722c247023 ("Bluetooth: Enable 6LoWPAN support for BT LE devices")
> Signed-off-by: Stephen Warren <swarren@nvidia.com>

Applied to net-next, thanks a lot.
