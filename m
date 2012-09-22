From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: send port changed when added
Date: Sat, 22 Sep 2012 15:45:55 -0400 (EDT)
Message-ID: <20120922.154555.1606849443023854084.davem@davemloft.net>
References: <1348333673-29860-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab2IVTp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:45:57 -0400
In-Reply-To: <1348333673-29860-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 22 Sep 2012 19:07:53 +0200

> On some hw, link is not up during adding iface to team. That causes event
> not being sent to userspace and that may cause confusion.
> Fix this bug by sending port changed event once it's added to team.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I'll apply this, thanks Jiri.
