From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qlogic: qla3xxx: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 20 Feb 2017 10:28:48 -0500 (EST)
Message-ID: <20170220.102848.1654431640603977173.davem@davemloft.net>
References: <1487459944-32311-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487459944-32311-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 19 Feb 2017 00:19:04 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
