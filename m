From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Thu, 27 Sep 2007 17:00:23 -0600
Message-ID: <m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com>
	<46FB6F1E.8070105@fr.ibm.com>
	<m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>
	<20070927.124552.69400277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40968 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756948AbXI0XBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 19:01:18 -0400
In-Reply-To: <20070927.124552.69400277.davem@davemloft.net> (David Miller's
	message of "Thu, 27 Sep 2007 12:45:52 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> Eric, pick an appropriate new non-conflicting number NOW.

Done.  My apologies for the confusion.  I thought the
way Cedric and the IBM guys were testing someone would have
shouted at me long before now.

> This adds unnecessary extra work for Andrew Morton, which he has
> enough of already.

Cedric made a good point that we will have conflicts of code
being added to the same place in nsproxy.c and the like.  So
I copied Andrew to give him a heads up.

I will gladly do what I can, to help.  Working against 3 trees
development at the moment is a bit of a development challenge.

Eric
