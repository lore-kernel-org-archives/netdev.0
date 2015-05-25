From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] rocker: unused parameter and const
 cleanups
Date: Mon, 25 May 2015 18:17:57 -0400 (EDT)
Message-ID: <20150525.181757.2291834753304841483.davem@davemloft.net>
References: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbbEYWSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 18:18:01 -0400
In-Reply-To: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Mon, 25 May 2015 14:28:34 +0900

> This series provides some minor though verbose cleanup of rocker.
> 
> The second patch depends on the first though it could be rebased.
> 
> I had previously asked for v2 to be put on hold while some bugs I had found
> in the rocker driver were shaken out. That has now happened and the bugs
> turned out to be unrelated.  Accordingly I am reposting the series.
> 
> * Changes v2 -> v3
>   - Rebase and update for new variables and parameters that may be const
> 
> * Changes v1 -> v2
>   - Found quite a few more variables and parameters to make const

Series applied, thanks Simon.
