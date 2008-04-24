From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix typo in net/ipv6/Kconfig
Date: Thu, 24 Apr 2008 03:47:45 -0700 (PDT)
Message-ID: <20080424.034745.213455935.davem@davemloft.net>
References: <20080424103950.GA6723@snafu.setup>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: youvegotmoxie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42720
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751140AbYDXKrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 06:47:46 -0400
In-Reply-To: <20080424103950.GA6723@snafu.setup>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Beasley <youvegotmoxie@gmail.com>
Date: Thu, 24 Apr 2008 06:39:50 -0400

> diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
> index eb0b808..56b4d86 100644
> --- a/net/ipv6/Kconfig
> +++ b/net/ipv6/Kconfig
> @@ -172,7 +172,7 @@ config IPV6_SIT
>           Tunneling means encapsulating data of one protocol type within
>           another protocol and sending it over a channel that understands the
>           encapsulating protocol. This driver implements encapsulation of IPv6
> -         into IPv4 packets. This is useful if you want to connect two IPv6
> +         into IPv4 packets. This is useful if you want to connect to IPv6
>           networks over an IPv4-only path.
> 
>           Saying M here will produce a module called sit.ko. If unsure, say Y.

Your email client corrupted the patch, it has turned tab characters
into spaces.

You should also be sure to post your networking patches to
netdev@vger.kernel.org as that's where the networking developers
listen.

Please also provide a proper Signed-off-by: line for your patch (see
linux/Docuemtnation/SubmittingPatches, section 5).

Thanks.
