From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] MAINTAINERS: PHY: Change maintainer to reviewer
Date: Tue, 24 Nov 2015 17:04:11 -0800
Message-ID: <1448413451.20113.20.camel@perches.com>
References: <1448407790-22336-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0075.hostedemail.com ([216.40.44.75]:56591 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932718AbbKYBEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 20:04:14 -0500
In-Reply-To: <1448407790-22336-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-24 at 15:29 -0800, Florian Fainelli wrote:
> Now that there is a reviewer role, add myself as reviewer since the PHY
> library code is maintained via the networking tree.

[]

> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -4195,7 +4195,7 @@ F:	include/linux/netfilter_bridge/
>  F:> 	> net/bridge/
>  
>  ETHERNET PHY LIBRARY
> -M:	Florian Fainelli <f.fainelli@gmail.com>
> +R:	Florian Fainelli <f.fainelli@gmail.com>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
>  F:	include/linux/phy.h

Just because the upstream path is not a tree you
manage doesn't mean you aren't a maintainer.

I think the status should be something other than
"Maintained" if you are not the maintainer.
