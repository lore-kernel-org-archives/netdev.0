From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: nuvoton: w90p910: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 22:35:31 -0500 (EST)
Message-ID: <20170212.223531.2159528346622192427.davem@davemloft.net>
References: <1486931909-18330-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcuos.com@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486931909-18330-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 12 Feb 2017 21:38:29 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
