From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] flow_dissector: remove bogus return in tipc
 section
Date: Sun, 17 May 2015 23:38:45 -0400 (EDT)
Message-ID: <20150517.233845.971636896781795267.davem@davemloft.net>
References: <1431689252-6830-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbbERDiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:38:46 -0400
In-Reply-To: <1431689252-6830-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 15 May 2015 13:27:32 +0200

> Fixes: 06635a35d13d42b9 ("flow_dissect: use programable dissector in skb_flow_dissect and friends")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Whoops, wonder how that snuck in there.

Applied, thanks Jiri.
