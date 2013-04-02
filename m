From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: fix smatch warnings inside datagram_poll
Date: Tue, 02 Apr 2013 16:40:25 -0400 (EDT)
Message-ID: <20130402.164025.2237059970586581339.davem@davemloft.net>
References: <20130402203414.24602.6059.stgit@jekeller-hub.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759559Ab3DBUka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 16:40:30 -0400
In-Reply-To: <20130402203414.24602.6059.stgit@jekeller-hub.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Tue,  2 Apr 2013 13:34:15 -0700

> The code for commit 1218a2a1d233fd604a41e584163ec291418f8ea8 actually turns out
> to be incorrect.

This commit object SHA ID is not correct, it should be
7d4c04fc170087119727119074e72445f2bb192b.

Also, when referencing commits, always follow the SHA ID with the commit
log message header line, enclosed in both parenthesis and double quotes.
