From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: Add support for Marvell 88E6240
Date: Thu, 11 Feb 2016 16:45:23 +0100
Message-ID: <20160211154523.GA23857@lunn.ch>
References: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 11, 2016 at 11:44:48AM +0100, Sascha Hauer wrote:
> The Marvell 88E6240 has been tested successfully without further
> changes. Add entry to the table of supported devices.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  drivers/net/dsa/mv88e6352.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
> index cc6c545..a47f52f 100644
> --- a/drivers/net/dsa/mv88e6352.c
> +++ b/drivers/net/dsa/mv88e6352.c
> @@ -25,6 +25,7 @@
>  static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
>  	{ PORT_SWITCH_ID_6172, "Marvell 88E6172" },
>  	{ PORT_SWITCH_ID_6176, "Marvell 88E6176" },
> +	{ PORT_SWITCH_ID_6240, "Marvell 88E6240" },
>  	{ PORT_SWITCH_ID_6320, "Marvell 88E6320" },
>  	{ PORT_SWITCH_ID_6320_A1, "Marvell 88E6320 (A1)" },
>  	{ PORT_SWITCH_ID_6320_A2, "Marvell 88e6320 (A2)" },
> -- 
> 2.7.0.rc3
> 
