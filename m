From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5]: soreuseport: Bind multiple sockets to the same
 port
Date: Tue, 22 Jan 2013 15:28:58 -0500 (EST)
Message-ID: <20130122.152858.733964025451561267.davem@davemloft.net>
References: <alpine.DEB.2.00.1301221142300.26333@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev@markandruth.co.uk,
	eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813Ab3AVU3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 15:29:06 -0500
In-Reply-To: <alpine.DEB.2.00.1301221142300.26333@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 22 Jan 2013 11:49:46 -0800 (PST)

> This series implements so_reuseport (SO_REUSEPORT socket option) for
> TCP and UDP.

Series applied, thanks Tom.
