From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mellanox: switchx2: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 08 Feb 2017 14:35:53 -0500 (EST)
Message-ID: <20170208.143553.154577922391325770.davem@davemloft.net>
References: <1486508853-29623-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486508853-29623-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed,  8 Feb 2017 00:07:33 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied, thanks.
