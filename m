From: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Subject: Re: [PATCH][MAINTAINERS]: The socketcan-core list is subscribers-only.
Date: Tue, 29 Apr 2008 10:11:33 +0200
Message-ID: <4816D835.7030705@volkswagen.de>
References: <4816C684.6090200@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxout1.volkswagen.de ([194.114.62.41]:2816 "EHLO
	mxout1.volkswagen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbYD2IL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 04:11:56 -0400
In-Reply-To: <4816C684.6090200@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
>
> When I posted a copy_to_user fixes, the list daemon refused to accept
> the Cc: <this-list>, because I was not a subscriber.
>
> I found, that other lists with such a feature are marked respectively
> in the MAINTAINERS file.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
> ---
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 36aadf6..bd92fdd 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1026,7 +1026,7 @@ P:        Urs Thuermann
>  M:     urs.thuermann@volkswagen.de
>  P:     Oliver Hartkopp
>  M:     oliver.hartkopp@volkswagen.de
> -L:     socketcan-core@lists.berlios.de
> +L:     socketcan-core@lists.berlios.de (subscribers-only)
>  W:     http://developer.berlios.de/projects/socketcan/
>  S:     Maintained
>  
>

Thanks Pavel!

I also thought about it - but i was too late ;-)

Acked-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>

Best regards,
Oliver

