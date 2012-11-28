From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: fix hw_features setup
Date: Wed, 28 Nov 2012 11:48:45 -0500 (EST)
Message-ID: <20121128.114845.552884314389038522.davem@davemloft.net>
References: <1354119190-16100-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab2K1Qsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:48:47 -0500
In-Reply-To: <1354119190-16100-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 28 Nov 2012 17:13:10 +0100

> Do this in the same way bonding does. This fixed setup resolves performance
> issues when using some cards with certain offloading.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
