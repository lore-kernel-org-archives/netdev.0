From: David Miller <davem@davemloft.net>
Subject: Re: pch_gbe oops with vlan
Date: Fri, 11 May 2012 16:36:54 -0400 (EDT)
Message-ID: <20120511.163654.747026598811714570.davem@davemloft.net>
References: <1336749810.31653.176.camel@edumazet-glaptop>
	<1336752516.31653.196.camel@edumazet-glaptop>
	<40680C535D6FE6498883F1640FACD44DDF9055@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andy.cress@us.kontron.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932157Ab2EKUg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 16:36:59 -0400
In-Reply-To: <40680C535D6FE6498883F1640FACD44DDF9055@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ummm, no.  You can't do this.

You replied to Eric Dumazet's patch posting, which is completely
unrelated to what you want to post about.  Then you edited the
Subject: and thought that was OK.

This is wrong, because the thread ID and other related fields still
refer to Eric's posting, so all thread indexing facilities still
think your posting is a reply to Eric's.

Don't do this, write a new email to the list properly.
