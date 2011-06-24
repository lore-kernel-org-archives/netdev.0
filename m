From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] MAINTAINERS: mark socketcan-core lists as
 subscribers-only
Date: Fri, 24 Jun 2011 02:30:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106240228440.17688@swampdragon.chaosbits.net>
References: <1308875142-10429-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: socketcan-core@lists.berlios.de,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:26112 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933606Ab1FXAjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 20:39:22 -0400
In-Reply-To: <1308875142-10429-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2011, Mike Frysinger wrote:

> The socketcan-core lists require subscription, so mark them as such.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  MAINTAINERS |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index f0358cd..d3765e8 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1639,7 +1639,7 @@ CAN NETWORK LAYER
>  M:	Oliver Hartkopp <socketcan@hartkopp.net>
>  M:	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
>  M:	Urs Thuermann <urs.thuermann@volkswagen.de>
> -L:	socketcan-core@lists.berlios.de
> +L:	socketcan-core@lists.berlios.de (subscribers-only)
>  L:	netdev@vger.kernel.org
>  W:	http://developer.berlios.de/projects/socketcan/
>  S:	Maintained
> @@ -1651,7 +1651,7 @@ F:	include/linux/can/raw.h
>  
>  CAN NETWORK DRIVERS
>  M:	Wolfgang Grandegger <wg@grandegger.com>
> -L:	socketcan-core@lists.berlios.de
> +L:	socketcan-core@lists.berlios.de (subscribers-only)
>  L:	netdev@vger.kernel.org
>  W:	http://developer.berlios.de/projects/socketcan/
>  S:	Maintained
> 

I just ran into this "subscribers only" policy recently - yeah, it should 
at least be noted in MAINTAINERS.

Patch looks good to me.

Reviewed-by: Jesper Juhl <jj@chaosbits.net>

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

