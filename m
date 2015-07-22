From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [v3, 2/9] fsl/fman: Add the FMan port FLIB
Date: Wed, 22 Jul 2015 09:55:53 -0700
Message-ID: <20150722095553.4cd028d1@urahara>
References: <1437564108-16490-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>, <scottwood@freescale.com>,
	<madalin.bucur@freescale.com>, <pebolle@tiscali.nl>,
	<joakim.tjernlund@transmode.se>, <ppc@mindchasers.com>
To: <igal.liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437564108-16490-1-git-send-email-igal.liberman@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Jul 2015 14:21:48 +0300
<igal.liberman@freescale.com> wrote:

> diff --git a/drivers/net/ethernet/freescale/fman/Kconfig b/drivers/net/ethernet/freescale/fman/Kconfig
> index 8aeae29..af42c3a 100644
> --- a/drivers/net/ethernet/freescale/fman/Kconfig
> +++ b/drivers/net/ethernet/freescale/fman/Kconfig
> @@ -5,3 +5,4 @@ config FSL_FMAN
>  	help
>  		Freescale Data-Path Acceleration Architecture Frame Manager
>  		(FMan) support
> +

Bogus blank line introduced at end of file?
Why was this not in patch 1?
