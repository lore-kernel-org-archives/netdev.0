From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fixed TPACKET V3 to signal poll when block is closed
 rather than every packet
Date: Thu, 18 Dec 2014 22:40:11 -0500 (EST)
Message-ID: <20141218.224011.175832100672931963.davem@davemloft.net>
References: <1418949139-21299-1-git-send-email-dan@dcollins.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dan@dcollins.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaLSDkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 22:40:18 -0500
In-Reply-To: <1418949139-21299-1-git-send-email-dan@dcollins.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Collins <dan@dcollins.co.nz>
Date: Fri, 19 Dec 2014 13:32:19 +1300

> + *		Dan Collins : Fixed TPACKET_V3 to wake poll when block is closed
> + *					rather than for every packet.

Since we now use real version control with commit messages, this
comment at the top of the source file is not an appropriate
place to log your change.
