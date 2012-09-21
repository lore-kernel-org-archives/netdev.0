From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: send port changed when added
Date: Fri, 21 Sep 2012 15:01:42 -0400 (EDT)
Message-ID: <20120921.150142.1121078984466626799.davem@davemloft.net>
References: <1348228319-11453-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933023Ab2IUTBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 15:01:43 -0400
In-Reply-To: <1348228319-11453-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 21 Sep 2012 13:51:59 +0200

> On some hw, link is not up during adding iface to team. That causes event
> not being sent to userspace and that may cause confusion.
> Fix this bug by sending port changed event once it's added to team.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks a lot Jiri.
