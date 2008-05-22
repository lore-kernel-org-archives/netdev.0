From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] Blackfin EMAC Driver: Removed duplicated include
 <linux/ethtool.h> in drivers/net/bfin_mac.c.
Date: Thu, 22 May 2008 06:22:16 -0400
Message-ID: <48354958.2060905@garzik.org>
References: <1210565644-4272-1-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Huang Weiyi <weiyi.huang@gmail.com>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59326 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936646AbYEVKWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:22:18 -0400
In-Reply-To: <1210565644-4272-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryan Wu wrote:
> From: Huang Weiyi <weiyi.huang@gmail.com>
> 
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  drivers/net/bfin_mac.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> index 89c0018..4144343 100644
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
> @@ -22,7 +22,6 @@
>  #include <linux/crc32.h>
>  #include <linux/device.h>
>  #include <linux/spinlock.h>
> -#include <linux/ethtool.h>
>  #include <linux/mii.h>
>  #include <linux/phy.h>

applied


