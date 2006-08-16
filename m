From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 7/7] [I/OAT] Add entries to MAINTAINERS for the DMA memcpy
 subsystem and ioatdma
Date: Tue, 15 Aug 2006 21:52:12 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0608152151430.7622@shark.he.net>
References: <20060816005337.8634.70033.stgit@gitlost.site>
 <20060816005350.8634.68292.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750750AbWHPEwO@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060816005350.8634.68292.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006, Chris Leech wrote:

> Signed-off-by: Chris Leech <christopher.leech@intel.com>
> ---
>
>  MAINTAINERS |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 21116cc..9ae73c9 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -881,6 +881,11 @@ M:	tori@unhappy.mine.nu
>  L:	linux-kernel@vger.kernel.org
>  S:	Maintained
>
> +DMA GENERIC MEMCPY SUBSYSTEM
> +P:	Chris Leech
> +M:	christopher.leech@intel.com
> +S:	Maintained
> +
>  DOCBOOK FOR DOCUMENTATION
>  P:	Martin Waitz
>  M:	tali@admingilde.org
> @@ -1469,6 +1474,11 @@ P:	Tigran Aivazian
>  M:	tigran@veritas.com
>  S:	Maintained
>
> +INTEL I/OAT DMA DRIVER
> +P:	Chris Leech
> +M:	christopher.leech@intel.com
> +S:	Supported
> +
>  INTEL IXP4XX RANDOM NUMBER GENERATOR SUPPORT
>  P:	Deepak Saxena
>  M:	dsaxena@plexity.net

Can you also add an appropriate mailing list for these,
such as netdev or lkml etc.?

Thanks,
-- 
~Randy
