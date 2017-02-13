From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: microchip: encx24j600: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Feb 2017 22:34:43 -0500 (EST)
Message-ID: <20170212.223443.686241810945829157.davem@davemloft.net>
References: <1486676538-3239-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeroen.de_wachter.ext@nokia.com, fw@strlen.de, mugunthanvnm@ti.com,
        akpm@linux-foundation.org, pmladek@suse.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486676538-3239-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu,  9 Feb 2017 22:42:18 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
