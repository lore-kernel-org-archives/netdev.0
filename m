From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2015-04-09
Date: Thu, 09 Apr 2015 14:42:15 -0400 (EDT)
Message-ID: <20150409.144215.236598036579647301.davem@davemloft.net>
References: <1428575588-24962-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbbDISmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:42:17 -0400
In-Reply-To: <1428575588-24962-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 9 Apr 2015 12:33:07 +0200

> 1) Prohibit the use/abuse of the xfrm netlink interface on
>    32/64 bit compatibility tasks. We need a full compat
>    layer before we can allow this. From Fan Du.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.

This is fine as a short term fix, but long term we should translate these data
structures.
