From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: removed redundant conditional
Date: Fri, 08 Aug 2014 10:22:33 -0700 (PDT)
Message-ID: <20140808.102233.61018398976947649.davem@davemloft.net>
References: <20140808082737.GA3847@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: executerx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbaHHRWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 13:22:36 -0400
In-Reply-To: <20140808082737.GA3847@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niv Yehezkel <executerx@gmail.com>
Date: Fri, 8 Aug 2014 04:27:37 -0400

> Since fib_lookup cannot return ESRCH no longer,
> checking for this error code is no longer neccesary.
> 
> Signed-off-by: Niv Yehezkel <executerx@gmail.com>

Applied, thank you.
