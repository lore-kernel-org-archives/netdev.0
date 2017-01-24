From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: broadcom: bnx2x: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 24 Jan 2017 13:49:52 -0500 (EST)
Message-ID: <20170124.134952.2268029151066885294.davem@davemloft.net>
References: <1485006196-6472-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485006196-6472-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 21 Jan 2017 14:43:16 +0100

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
> - also move to new api for bnx2x_vf

Applied.
