From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: nicvf: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 10 Dec 2016 17:32:06 -0500 (EST)
Message-ID: <20161210.173206.646424069710654483.davem@davemloft.net>
References: <1481378448-22278-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481378448-22278-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 10 Dec 2016 15:00:48 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
