From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH rfc 1/5] r8169: style cleanups.
Date: Wed, 4 May 2011 21:17:28 +0200
Message-ID: <20110504191728.GA20197@electric-eye.fr.zoreil.com>
References: <20110427203654.GD19708@electric-eye.fr.zoreil.com> <1303937974.24299.92.camel@Joe-Laptop> <20110427.140043.183040785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, netdev@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41532 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab1EDT0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 15:26:52 -0400
Content-Disposition: inline
In-Reply-To: <20110427.140043.183040785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: Joe Perches <joe@perches.com>
[...]
> >> -	if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
> >> -	    tp->mac_version == RTL_GIGA_MAC_VER_33)
> >> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_32) ||
> >> +	    (tp->mac_version == RTL_GIGA_MAC_VER_33))
> > 
> > Shrug.  I don't think this is better.
> 
> Yeah, same here.

Ok. I'll have the driver consistently use the former then.

Thanks.

-- 
Ueimor
