From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2013-06-26
Date: Wed, 26 Jun 2013 13:23:57 -0700 (PDT)
Message-ID: <20130626.132357.1435782534309083357.davem@davemloft.net>
References: <1372248098-19876-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954Ab3FZUYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 16:24:00 -0400
In-Reply-To: <1372248098-19876-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 26 Jun 2013 14:01:37 +0200

> Just one patch this time.
> 
> 1) Drop packets when the matching SA is in larval state and add a
>    statistic counter for that. From Fan Du.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
