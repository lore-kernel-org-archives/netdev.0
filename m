From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/2] team: add netpoll support
Date: Tue, 17 Jul 2012 09:02:46 -0700 (PDT)
Message-ID: <20120717.090246.433539164805055819.davem@davemloft.net>
References: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab2GQQCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 12:02:47 -0400
In-Reply-To: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 17 Jul 2012 17:22:34 +0200

> Also contains a little change to netpoll core.
> 
> Jiri Pirko (2):
>   netpoll: move np->dev and np->dev_name init into __netpoll_setup()
>   team: add netpoll support

Both applied, thanks Jiri.
