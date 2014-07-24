From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2014-07-23
Date: Wed, 23 Jul 2014 21:57:28 -0700 (PDT)
Message-ID: <20140723.215728.1778572314755094168.davem@davemloft.net>
References: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaGXE53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 00:57:29 -0400
In-Reply-To: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 23 Jul 2014 10:18:05 +0200

> Just two fixes this time, both are stable candidates.
> 
> 1) Fix the dst_entry refcount on socket policy usage.
> 
> 2) Fix a wrong SPI check that prevents AH SAs from getting
>    installed, dependent on the SPI. From Tobias Brunner. 
> 
> Please pull or let me know if there are problems.

Pulled, and both patches queued up for -stable, thanks.
