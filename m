From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2013-08-28
Date: Thu, 29 Aug 2013 16:08:00 -0400 (EDT)
Message-ID: <20130829.160800.2010683317157666288.davem@davemloft.net>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659Ab3H2UIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:08:02 -0400
In-Reply-To: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 28 Aug 2013 13:04:47 +0200

> This pull request fixes some issues that arise when 6in4 or 4in6 tunnels
> are used in combination with IPsec, all from Hannes Frederic Sowa and a
> null pointer dereference when queueing packets to the policy hold queue.
 ...
> Please pull or let me know if there are problems.

Pulled, thanks!
