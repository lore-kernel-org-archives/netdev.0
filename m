From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] phy: mdio-thunder: Fix some Kconfig typos
Date: Wed, 16 Mar 2016 16:26:00 -0700
Message-ID: <56E9EB88.5000608@caviumnetworks.com>
References: <1458170617-31784-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0066.outbound.protection.outlook.com ([157.56.111.66]:51712
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S935317AbcCPX0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 19:26:09 -0400
In-Reply-To: <1458170617-31784-1-git-send-email-afaerber@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 04:23 PM, Andreas F=C3=A4rber wrote:
> Drop two extra occurrences of "on" in option title and help text.
>
> Fixes: 379d7ac7ca31 ("phy: mdio-thunder: Add driver for Cavium Thunde=
r SoC MDIO buses.")
> Cc: David Daney <david.daney@cavium.com>
> Signed-off-by: Andreas F=C3=A4rber <afaerber@suse.de>

=46WIW:

Acked-by: David Daney <david.daney@cavium.com>

> ---
>   drivers/net/phy/Kconfig | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 075a4cc175b1..6dad9a9c356c 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -197,13 +197,13 @@ config MDIO_OCTEON
>   	  drivers on some systems.
>
>   config MDIO_THUNDER
> -	tristate "Support for MDIO buses on on ThunderX SOCs"
> +	tristate "Support for MDIO buses on ThunderX SOCs"
>   	depends on 64BIT
>   	depends on PCI
>   	select MDIO_CAVIUM
>   	help
>   	  This driver supports the MDIO interfaces found on Cavium
> -	  ThunderX SoCs when the MDIO bus device appears on as a PCI
> +	  ThunderX SoCs when the MDIO bus device appears as a PCI
>   	  device.
>
>
>
