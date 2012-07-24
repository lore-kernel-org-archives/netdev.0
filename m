From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: init error value to 0 in
 team_netpoll_setup()
Date: Tue, 24 Jul 2012 13:56:52 -0700 (PDT)
Message-ID: <20120724.135652.824912506261373394.davem@davemloft.net>
References: <1343128848-1284-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab2GXU4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:56:53 -0400
In-Reply-To: <1343128848-1284-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 24 Jul 2012 13:20:48 +0200

> This will ensure correct value is returned in case the port list is empty.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
