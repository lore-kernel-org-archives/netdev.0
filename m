From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] MAINTAINERS: Update mailing list for Renesas SoC
 Development
Date: Tue, 19 Jan 2016 14:10:45 +0300
Message-ID: <569E19B5.1000206@cogentembedded.com>
References: <1453079073-30937-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-media@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1453079073-30937-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/18/2016 4:04 AM, Simon Horman wrote:

> Update the mailing list used for development of support for
> Renesas SoCs and related drivers.
>
> Up until now the linux-sh mailing list has been used, however,
> Renesas SoCs are now much wider than the SH architecture and there
> is some desire from some for the linux-sh list to refocus on
> discussion of the work on the SH architecture.
>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
> Cc: Geert Uytterhoeven <geert+renesas@glider.be>
> Cc: Magnus Damm <magnus.damm@gmail.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
> ---
> * This patch applies on top of Linus's tree where currently the head commit
>    is 984065055e6e ("Merge branch 'drm-next' of
>    git://people.freedesktop.org/~airlied/linux")
>
>    This has been used as a base instead of v4.4 so that it is based on the
>    following two commits which affect it:
>    - 1a4ca6dd3dc8 ("MAINTAINERS: Add co-maintainer for Renesas Pin Controllers")
>    - 3e46c3973cba ("MAINTAINERS: add Renesas usb2 phy driver")
> ---
>   MAINTAINERS | 16 ++++++++--------
>   1 file changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 1d23f701489c..52a6ba79fa3f 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
[...]
> @@ -8413,7 +8413,7 @@ F:	drivers/pinctrl/intel/
>   PIN CONTROLLER - RENESAS
>   M:	Laurent Pinchart <laurent.pinchart@ideasonboard.com>
>   M:	Geert Uytterhoeven <geert+renesas@glider.be>
> -L:	linux-sh@vger.kernel.org
> +L:	linux-renesas-soc@vger.kernel.org
>   S:	Maintained
>   F:	drivers/pinctrl/sh-pfc/
>
> @@ -9019,13 +9019,13 @@ F:	include/linux/rpmsg.h
>   RENESAS ETHERNET DRIVERS
>   R:	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>   L:	netdev@vger.kernel.org
> -L:	linux-sh@vger.kernel.org
> +L:	linux-renesas-soc@vger.kernel.org
>   F:	drivers/net/ethernet/renesas/
>   F:	include/linux/sh_eth.h

    If SH people are OK with these 2 chunks (these entries cover the drivers 
used by SH as well):

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
