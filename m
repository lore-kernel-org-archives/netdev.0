From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: aquantia: atlantic: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 31 Jan 2017 13:12:10 -0500 (EST)
Message-ID: <20170131.131210.33717135353496768.davem@davemloft.net>
References: <1485813882-9887-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexander.Loktionov@aquantia.com, Pavel.Belous@aquantia.com,
        Dmitry.Bezrukov@aquantia.com, vomlehn@texas.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485813882-9887-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon, 30 Jan 2017 23:04:42 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - add support and advertise for TP

Applied, thanks.
