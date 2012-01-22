From: David Miller <davem@davemloft.net>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Sun, 22 Jan 2012 14:14:47 -0500 (EST)
Message-ID: <20120122.141447.1622071157220040891.davem@davemloft.net>
References: <4F1AFA84.5050201@candelatech.com>
	<20120121.134036.1565691107664746948.davem@davemloft.net>
	<4F1C3DF5.8070802@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab2AVTPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:15:03 -0500
In-Reply-To: <4F1C3DF5.8070802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Sun, 22 Jan 2012 08:48:53 -0800

> Just to make sure I understand you: You dislike any possible method
> of changing the behaviour, not just the ones I listed?

That's correct.

And please don't create dependencies on such a change in behavior in
distributions, otherwise you obliterate the entire reason why I don't
want the behavior changed.

There is no reason to change this, it's been like this for more than
10 years and no alien planet has exploded as a result even after all
of this time.

Just leave it be, I beg you.
