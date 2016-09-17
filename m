From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] MAINTAINERS: Gary Zambrano's email is bouncing
Date: Sat, 17 Sep 2016 15:51:49 -0700
Message-ID: <1474152709.1954.8.camel@perches.com>
References: <1474151235-16558-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, michael.chan@broadcom.com,
        bcm-kernel-feedback-list@broadcom.com, zajec5@gmail.com,
        hauke@hauke-m.de
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0220.hostedemail.com ([216.40.44.220]:53256 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754733AbcIQWvw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:51:52 -0400
In-Reply-To: <1474151235-16558-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-09-17 at 15:27 -0700, Florian Fainelli wrote:
> Gary has not been with Broadcom for some time now, replace his address
> with the internal mailing-list used for other entries.
> 
> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> --- 
> Michael,
> 
> Since this is an old driver, not sure who could step up as a maintainer
> for b44?
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -2500,8 +2500,8 @@ S:	Supported

> F:	kernel/bpf/
>  
>  BROADCOM B44 10/100 ETHERNET DRIVER
> -M:	Gary Zambrano <zambrano@broadcom.com>
>  L:	netdev@vger.kernel.org
> +M:	bcm-kernel-feedback-list@broadcom.com
>  S:	Supported
>  F:	drivers/net/ethernet/broadcom/b44.*

Without an actual maintainer, this should really be
orphan and not supported.

And the M: bcm-kernel-feedback-list@ should be L:

BCM4401 NICs are essentially from 2002.

Does anyone really use these any longer with a
current distribution or kernel version?
