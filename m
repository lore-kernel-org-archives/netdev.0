From: David Miller <davem@davemloft.net>
Subject: Re: Problem with unregister_netdevice
Date: Fri, 04 Jan 2013 12:52:14 -0800 (PST)
Message-ID: <20130104.125214.790250863069806993.davem@davemloft.net>
References: <20130104142241.GA17526@seeking.truth.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vasko@truth.sk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556Ab3ADUwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 15:52:15 -0500
In-Reply-To: <20130104142241.GA17526@seeking.truth.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomas Vasko <vasko@truth.sk>
Date: Fri, 4 Jan 2013 15:22:41 +0100

> From bisecting on .../git/torvalds/linux-2.6.git it seems the culprit is
> this commit: 81166dd6fa8eb780b2132d32fbc77eb6ac04e44e

Please quote the commit message of the commit next time when
referencing a commit, it saves us a lot of time.
