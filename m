From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] net: phy: marvell: make some functions static
Date: Sun, 04 Jun 2017 19:55:49 -0400 (EDT)
Message-ID: <20170604.195549.1999857552284832975.davem@davemloft.net>
References: <20170602141334.26506-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602141334.26506-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  2 Jun 2017 15:13:34 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> functions m88e1510_get_temp_critical, m88e1510_set_temp_critical and
> m88e1510_get_temp_alarm can be made static as they not need to be
> in global scope.
> 
> Cleans up sparse warnings:
>  "symbol 'm88e1510_get_temp_alarm' was not declared. Should it be static?"
>  "symbol 'm88e1510_get_temp_critical' was not declared. Should it be
>   static?"
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next, thanks.
