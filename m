From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 3c59x: Add software timestamping
Date: Thu, 19 Dec 2013 14:33:24 -0500 (EST)
Message-ID: <20131219.143324.961008729509428288.davem@davemloft.net>
References: <1387207226-17076-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754993Ab3LSTd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:33:26 -0500
In-Reply-To: <1387207226-17076-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Mon, 16 Dec 2013 10:20:26 -0500

> Added software timestamping ability. Tested with linuxptp and synchronized
> clocks to an average of less than 200 microseconds on 10 megabit ethernet.
> 
> Tested on both Vortex and Boomerang models.
> 
> Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>

Applied, thanks.
