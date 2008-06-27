From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: sh_eth: Fix compile error sh_eth
Date: Fri, 27 Jun 2008 02:09:02 -0400
Message-ID: <486483FE.9090709@garzik.org>
References: <4858D619.80403@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>,
	Linux-sh <linux-sh@vger.kernel.org>,
	shimoda.yoshihiro@renesas.com
To: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4858D619.80403@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nobuhiro Iwamatsu wrote:
> Fix compile error on sh_eth and remove base address macro.
> 
> Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
> ---
>  drivers/net/sh_eth.c |    4 ++--
>  drivers/net/sh_eth.h |    4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)

applied


