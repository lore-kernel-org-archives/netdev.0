From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Update maintainers
Date: Thu, 09 Apr 2009 13:12:28 -0700
Message-ID: <1239307948.29975.9.camel@localhost>
References: <1239292061.3264.20.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2738 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935959AbZDIUMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 16:12:36 -0400
In-Reply-To: <1239292061.3264.20.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-09 at 16:47 +0100, Ben Hutchings wrote:
> Essentially all networking changes go through David Miller.
> Jeff Garzik no longer handles device drivers separately.
> I think this reflects current reality...
>  NETWORKING [GENERAL]
> -P:	Networking Team
> -M:	netdev@vger.kernel.org
> +P:	David S. Miller
> +M:	davem@davemloft.net
>  L:	netdev@vger.kernel.org
>  W:	http://linux-net.osdl.org/
> +T:	git kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
>  S:	Maintained
>  
>  NETWORKING [IPv4/IPv6]

Maybe also change the link to
http://www.linuxfoundation.org/en/Net

Perhaps:

NETWORKING [GENERAL]
P:	David S. Miller
M:	davem@davemloft.net
L:	netdev@vger.kernel.org
W:	http://www.linuxfoundation.org/en/Net
T:	git kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
S:	Maintained
F:	drivers/net/
F:	include/net/
F:	net/


