From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-04-11
Date: Thu, 11 Apr 2013 16:15:22 -0400 (EDT)
Message-ID: <20130411.161522.88291238581541801.davem@davemloft.net>
References: <1365666969-22645-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3DKUP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 16:15:27 -0400
In-Reply-To: <1365666969-22645-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 11 Apr 2013 09:56:07 +0200

> 1)  Allow to avoid copying DSCP during encapsulation
>     by setting a SA flag. From Nicolas Dichtel.
> 
> 2) Constify the netlink dispatch table, no need to modify it
>    at runtime. From Mathias Krause.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
