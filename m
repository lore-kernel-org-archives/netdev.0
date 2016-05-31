From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fib_rules: Added NLM_F_EXCL support to
 fib_nl_newrule
Date: Tue, 31 May 2016 14:09:26 -0700 (PDT)
Message-ID: <20160531.140926.656960580778250121.davem@davemloft.net>
References: <574C051B.90706@nokia.com>
	<7ef40a87-2b63-dfee-e019-4a2f0aec5507@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mateusz.bajorski@nokia.com, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcEaVJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 17:09:28 -0400
In-Reply-To: <7ef40a87-2b63-dfee-e019-4a2f0aec5507@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 30 May 2016 20:21:29 -0600

> missing a namespace (fr_net) compare. Everything else is relative to
> it.
> 
> I suggest making the rule compare a helper function.

I also explicitly asked the submitted to use a helper function.
