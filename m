From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM]: Add module alias for transformation type.
Date: Tue, 26 Jun 2007 23:58:07 -0700 (PDT)
Message-ID: <20070626.235807.131105320.davem@davemloft.net>
References: <1180067003902-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, jmorris@namei.org,
	kazunori@miyazawa.org, mk@linux-ipv6.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751330AbXF0G5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 02:57:48 -0400
In-Reply-To: <1180067003902-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: nakam@linux-ipv6.org
Date: Fri, 25 May 2007 13:23:23 +0900

> Hi Ingo and all,
> 
> This is the third one of MIPv6 module patch. It can be applied
> after two patches which are already sent to the list.
> Could you review it?
> 
> 
> It is clean-up for XFRM type modules and adds aliases with its
> protocol:
>  ESP, AH, IPCOMP, IPIP and IPv6 for IPsec
>  ROUTING and DSTOPTS for MIPv6
> 
> It is almost the same thing as XFRM mode alias, but it is added
> new defines XFRM_PROTO_XXX for preprocessing since some protocols
> are defined as enum.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

I have also applied this patch, thank you!
