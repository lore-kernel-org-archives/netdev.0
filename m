From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: tulip: update MAINTAINER status to Orphan
Date: Thu, 19 Nov 2015 18:29:14 -0800
Message-ID: <564E857A.4020609@gmail.com>
References: <1447984572-23959-1-git-send-email-grantgrundler@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Helge Deller <deller@gmx.de>,
	Grant Grundler <grundler@parisc-linux.org>
To: Grant Grundler <grantgrundler@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36127 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030192AbbKTCaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 21:30:16 -0500
In-Reply-To: <1447984572-23959-1-git-send-email-grantgrundler@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/11/15 17:56, Grant Grundler wrote:
> From: Grant Grundler <grundler@parisc-linux.org>
> 
> I haven't had any PCI tulip HW for the past ~5 years. I have
> been reviewing tulip patches and can continue doing that.
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> ---
> I'm also proposing to add linux-parisc to the list since AFAIK, all
> parisc systems but the C8000 workstations (PA8800/PA8900 CPU)
> use tulip for onboard LAN.
> 
> Specific mips and alpha systems also care about tulip driver too.
> But I don't know either well enough to suggest respective mailing
> lists should see every tulip patch.

For MIPS, is not Cobalt the primary (and sole) user? You could add
linux-mips@linux-mips.org if that helps. My Cobalt stayed behind me when
I moved to the US, so outside of Yoichi, I am not sure who else cares
these days...

> 
>  MAINTAINERS | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ea17512..ec07061 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -10888,9 +10888,9 @@ S:	Maintained
>  F:	drivers/media/tuners/tua9001*
>  
>  TULIP NETWORK DRIVERS
> -M:	Grant Grundler <grundler@parisc-linux.org>
>  L:	netdev@vger.kernel.org
> -S:	Maintained
> +L:	linux-parisc@vger.kernel.org
> +S:	Orphan
>  F:	drivers/net/ethernet/dec/tulip/
>  
>  TUN/TAP driver
> 


-- 
Florian
