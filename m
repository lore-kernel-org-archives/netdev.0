From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] bonding : LOCKDEP warning
Date: Sat, 22 Oct 2011 03:58:50 -0400 (EDT)
Message-ID: <20111022.035850.2034646410662956642.davem@davemloft.net>
References: <1319268987.6180.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab1JVH6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 03:58:53 -0400
In-Reply-To: <1319268987.6180.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Oct 2011 09:36:27 +0200

> On latest net-next I got following splat

I suspect Biederman's namespace patch set.

Eric B. please take a look.
