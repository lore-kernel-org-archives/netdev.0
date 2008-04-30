From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV6]: Compilation fix for compat MCAST_MSFILTER
 sockopts.
Date: Wed, 30 Apr 2008 14:50:28 -0700 (PDT)
Message-ID: <20080430.145028.58393157.davem@davemloft.net>
References: <481875DF.2020401@openvz.org>
	<OF3F5D943F.5B85126C-ON8825743B.004ED1BA-8825743B.004F51C2@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53366
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933168AbYD3Vu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:50:29 -0400
In-Reply-To: <OF3F5D943F.5B85126C-ON8825743B.004ED1BA-8825743B.004F51C2@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 30 Apr 2008 07:26:29 -0700

> Pavel,
> Definitely should be in compat_ipv6_getsockopt() as the original was-- I 
> hope
> your patch doesn't do the same thing when applied!
> 
> Good catch!
>                                                         +-DLS
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com>

Applied, thanks guys.
