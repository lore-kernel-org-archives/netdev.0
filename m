From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/15] ipv4: Adjust semantics of rt->rt_gateway.
Date: Wed, 18 Jul 2012 12:00:13 -0700 (PDT)
Message-ID: <20120718.120013.1267407239598992095.davem@davemloft.net>
References: <20120718.112346.920698833832945112.davem@davemloft.net>
	<1342637834.2013.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557Ab2GRTAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:00:14 -0400
In-Reply-To: <1342637834.2013.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 18 Jul 2012 11:57:14 -0700

> maybe use the moderately common gcc ?: extension

Yes, or even better a helper function.

I'll do something about this before I push it out for real, thanks
Joe.
