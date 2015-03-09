From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] mpls: Spelling: s/conceved/conceived/, s/as/a/
Date: Mon, 09 Mar 2015 09:45:13 -0500
Message-ID: <87lhj62ps6.fsf@x220.int.ebiederm.org>
References: <1425902088-20435-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37112 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbbCIOsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 10:48:52 -0400
In-Reply-To: <1425902088-20435-1-git-send-email-geert+renesas@glider.be>
	(Geert Uytterhoeven's message of "Mon, 9 Mar 2015 12:54:48 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert Uytterhoeven <geert+renesas@glider.be> writes:

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>  net/mpls/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
> index f4286ee7e2b03878..dfca485863e978d9 100644
> --- a/net/mpls/Kconfig
> +++ b/net/mpls/Kconfig
> @@ -7,9 +7,9 @@ menuconfig MPLS
>  	default n
>  	---help---
>  	  MultiProtocol Label Switching routes packets through logical
> -	  circuits.  Originally conceved as a way of routing packets at
> +	  circuits.  Originally conceived as a way of routing packets at
>  	  hardware speeds (before hardware was capable of routing ipv4 packets),
> -	  MPLS remains as simple way of making tunnels.
> +	  MPLS remains a simple way of making tunnels.
>  
>  	  If you have not heard of MPLS you probably want to say N here.
