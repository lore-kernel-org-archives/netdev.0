From: Felipe W Damasio <felipewd@terra.com.br>
Subject: Re: [patch 4/4]  8139cp net driver: add MODULE_VERSION
Date: Sat, 20 Nov 2004 01:01:42 -0200
Message-ID: <419EB396.9020406@terra.com.br>
References: <E1CVLFO-0002Im-G4@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CVLFO-0002Im-G4@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi Max.

	That has been on Jeff's net-dev queue for a while,

	Cheers,

Felipe

janitor@sternwelten.at wrote:
> 
> 
> 	Hi Jeff,
> 
> 	Add MODULE_VERSION to 8139cp net driver.
> 
> 	Cheers,
> 
> Felipe
> 
> 
> Signed-off-by: Felipe W Damasio <felipewd@terra.com.br>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> 
> ---
> 
>  linux-2.6.10-rc2-bk4-max/drivers/net/8139cp.c |    1 +
>  1 files changed, 1 insertion(+)
> 
> diff -puN drivers/net/8139cp.c~add_module_version-drivers_net_8139cp drivers/net/8139cp.c
> --- linux-2.6.10-rc2-bk4/drivers/net/8139cp.c~add_module_version-drivers_net_8139cp	2004-11-19 17:18:43.000000000 +0100
> +++ linux-2.6.10-rc2-bk4-max/drivers/net/8139cp.c	2004-11-19 17:18:43.000000000 +0100
> @@ -91,6 +91,7 @@ KERN_INFO DRV_NAME ": 10/100 PCI Etherne
>  
>  MODULE_AUTHOR("Jeff Garzik <jgarzik@pobox.com>");
>  MODULE_DESCRIPTION("RealTek RTL-8139C+ series 10/100 PCI Ethernet driver");
> +MODULE_VERSION(DRV_VERSION);
>  MODULE_LICENSE("GPL");
>  
>  static int debug = -1;
> _
> 
> 
