From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] phy/bitbang: missing MODULE_LICENSE
Date: Fri, 19 Oct 2007 23:03:54 -0400
Message-ID: <4719701A.2030805@pobox.com>
References: <20070920220043.GA28769@loki.buserror.net>	<20070920220123.GG28784@loki.buserror.net> <20071018122021.2acd128d.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43439 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756995AbXJTDEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 23:04:00 -0400
In-Reply-To: <20071018122021.2acd128d.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Missing MODULE_LICENSE(), loading this module taints the kernel.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/phy/mdio-bitbang.c |    2 ++
>  1 file changed, 2 insertions(+)

applied this and the NAPI_Howto Kconfig patch


