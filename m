From: David Miller <davem@davemloft.net>
Subject: Re: Traceroute and "ping" sockets: some questions
Date: Fri, 19 Aug 2011 07:00:22 -0700 (PDT)
Message-ID: <20110819.070022.391669829596734914.davem@davemloft.net>
References: <4E4E4DF6.2020509@odu.neva.ru>
	<20110819.062249.2234872106788628654.davem@davemloft.net>
	<4E4E6B8A.1030707@odu.neva.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buc@odusz.so-cdu.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab1HSOAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:00:54 -0400
In-Reply-To: <4E4E6B8A.1030707@odu.neva.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Date: Fri, 19 Aug 2011 17:56:26 +0400

> Why then there is "net/ipv4/ping_group_range" restrictions, with
> default values (low=1, high=0) which denies this way even for root?

While we shake out the bugs and better understand the security
implications of this feature.  One this is resolved we can deprecate
this.
