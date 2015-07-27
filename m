From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] niu: don't count tx error twice in case of
 headroom realloc fails
Date: Sun, 26 Jul 2015 21:18:10 -0700 (PDT)
Message-ID: <20150726.211810.1696228474695857128.davem@davemloft.net>
References: <1437646837-5631-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbbG0ESL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 00:18:11 -0400
In-Reply-To: <1437646837-5631-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 23 Jul 2015 12:20:37 +0200

> Fixes: a3138df9 ("[NIU]: Add Sun Neptune ethernet driver.")
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thank you.
