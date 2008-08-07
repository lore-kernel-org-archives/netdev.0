From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] WAN: remove extra help text from HDLC_PPP config option
Date: Thu, 07 Aug 2008 04:00:27 -0400
Message-ID: <489AAB9B.1010107@garzik.org>
References: <m3vdzq4rdg.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59668 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbYHGIAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 04:00:31 -0400
In-Reply-To: <m3vdzq4rdg.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> Remove extra help text from HDLC_PPP config option.
>=20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>
>=20
> diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
> index d3c2773..8f3ac39 100644
> --- a/drivers/net/wan/Kconfig
> +++ b/drivers/net/wan/Kconfig
> @@ -154,8 +154,6 @@ config HDLC_PPP
>  	help
>  	  Generic HDLC driver supporting PPP over WAN connections.
> =20
> -	  It will be replaced by new PPP implementation in Linux 2.6.26.
> -
>  	  If unsure, say N.

applied


