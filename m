From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 1/2] tcp: move TCP_ECN_create_request out of header
Date: Mon, 29 Sep 2014 14:41:43 -0400 (EDT)
Message-ID: <20140929.144143.1794311159838009963.davem@davemloft.net>
References: <1411988910-23710-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbaI2Slp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:41:45 -0400
In-Reply-To: <1411988910-23710-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 29 Sep 2014 13:08:29 +0200

> After Octavian Purdilas tcp ipv4/ipv6 unification work this helper only
> has a single callsite.
> 
> While at it, convert name to lowercase, suggested by Stephen.
> 
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
