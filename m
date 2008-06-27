From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: sh_eth: Add support of SH7763 to sh_eth
Date: Fri, 27 Jun 2008 02:09:14 -0400
Message-ID: <4864840A.3060003@garzik.org>
References: <485A3437.4010902@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Nobuhiro Iwamatsu <iwamatsu@nigauri.org>,
	Linux-sh <linux-sh@vger.kernel.org>,
	Paul Mundt <lethal@linux-sh.org>
To: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <485A3437.4010902@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nobuhiro Iwamatsu wrote:
> SH7763 has Ethernet core same as SH7710/SH7712.
> Positions of some registry are different, but the basic part is the same.
> I add support of ethernet of sh7763 to sh_eth.
> 
> Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
> ---
>  drivers/net/Kconfig  |    4 +-
>  drivers/net/sh_eth.c |  202 ++++++++++++++++++++-----
>  drivers/net/sh_eth.h |  425 +++++++++++++++++++++++++++++++++++++-------------
>  3 files changed, 482 insertions(+), 149 deletions(-)

ACK but failed to apply


