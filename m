From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] SLCAN/SLIP fixes and performance
Date: Fri, 20 Sep 2013 15:39:17 -0400 (EDT)
Message-ID: <20130920.153917.223605052660606273.davem@davemloft.net>
References: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nautsch2@gmail.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1379093833-4949-1-git-send-email-nautsch2@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andre Naujoks <nautsch2@gmail.com>
Date: Fri, 13 Sep 2013 19:37:10 +0200

> these are some loosely related patches, that fix an ancient locking problem in
> the slip and slcan drivers, add general ASCII-HEX to bin functions for
> uppercase ASCII, fix the handling of CAN RTR frames in the slcan driver
> and increase the performance for the slcan driver.
> 
> As these patches mainly contain fixes for the slip/slcan drivers that require
> a tty layer fix included in 3.11, I would suggest to get the patches in via
> the net tree for the 3.12 cycle. They should apply properly on the latest net
> and mainline tree.

Applied thanks.
