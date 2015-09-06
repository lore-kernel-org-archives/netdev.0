From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: kill default_pref field of struct
 fib_rules_ops
Date: Sat, 05 Sep 2015 22:00:40 -0700 (PDT)
Message-ID: <20150905.220040.768580139044156666.davem@davemloft.net>
References: <1441198992-25359-1-git-send-email-phil@nwl.cc>
	<1441278622-24679-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbbIFFAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 01:00:41 -0400
In-Reply-To: <1441278622-24679-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Thu,  3 Sep 2015 13:10:22 +0200

> Since now all users of that field have been converted to use the generic
> function fib_default_rule_pref() when assigning to it, fib_nl_newrule()
> may just use it directly instead.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

I did not instruct you to submit this change assuming I had applied
your ipv6 one.  Which I did not and will not do.

Instead, I want you to do it all in one go.

Thanks.
