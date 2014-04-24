From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: forbid incorrect fall-through in notifier
Date: Thu, 24 Apr 2014 13:26:58 -0400 (EDT)
Message-ID: <20140424.132658.370079147925564583.davem@davemloft.net>
References: <1398255475-9541-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581AbaDXR1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:27:00 -0400
In-Reply-To: <1398255475-9541-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 23 Apr 2014 14:17:55 +0200

> There are two breaks missing there. The result is that userspace
> receives multiple messages which might be confusing.
> 
> Introduced-by: 3d249d4c "net: introduce ethernet teaming device"
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
