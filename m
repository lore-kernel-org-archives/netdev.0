From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net] hyper-v: Add myself as additional MAINTAINER
Date: Thu, 5 Jan 2017 18:43:24 +0100
Message-ID: <20170105174324.GA7504@kroah.com>
References: <20170105173626.4657-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kys@microsoft.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:55856 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754051AbdAERnE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 12:43:04 -0500
Content-Disposition: inline
In-Reply-To: <20170105173626.4657-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 05, 2017 at 09:36:26AM -0800, Stephen Hemminger wrote:
> Update the Hyper-V MAINTAINERS to include myself.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  MAINTAINERS | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index ea11bb03f550..7542341d8155 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5963,6 +5963,7 @@ F:	drivers/media/platform/sti/hva
>  Hyper-V CORE AND DRIVERS
>  M:	"K. Y. Srinivasan" <kys@microsoft.com>
>  M:	Haiyang Zhang <haiyangz@microsoft.com>
> +M:	Stephen Hemminger <sthemmin@microsoft.com>

No objection from me, they need all the help they can get :)

But I would like an ack from the current maintainers that this is ok
first.

thanks,

greg k-h
