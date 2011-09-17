From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: deal with multiple COOKIE_ECHO chunks
Date: Sat, 17 Sep 2011 01:02:08 -0400 (EDT)
Message-ID: <20110917.010208.1774449645459771823.davem@davemloft.net>
References: <20110830072010.94AE98132707@regina.usersys.redhat.com>
	<20110916.171747.406895441960738806.davem@davemloft.net>
	<20084.9283.714998.398630@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com
To: makc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1IQFC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 01:02:28 -0400
In-Reply-To: <20084.9283.714998.398630@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Matveev <makc@redhat.com>
Date: Sat, 17 Sep 2011 14:38:27 +1000

> Sorry about it - I did check it with checkpatch.pl and it was happy:

checkpatch doesn't look thoroughly for these things, use
something like "git apply --check --whitespace=error-all"
for validation instead.
