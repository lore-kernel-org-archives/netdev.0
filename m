From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] bridge: use dev->addr_assign_type to see if
 user change mac
Date: Mon, 11 Feb 2013 14:18:03 -0500 (EST)
Message-ID: <20130211.141803.1383455953498483924.davem@davemloft.net>
References: <1360532461-21003-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758803Ab3BKTSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:18:06 -0500
In-Reply-To: <1360532461-21003-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 10 Feb 2013 22:41:01 +0100

> And remove no longer used br->flags.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
