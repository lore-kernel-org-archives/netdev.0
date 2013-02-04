From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/3] team: couple of patches
Date: Mon, 04 Feb 2013 14:56:39 -0500 (EST)
Message-ID: <20130204.145639.1716753274327941685.davem@davemloft.net>
References: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805Ab3BDT4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 14:56:44 -0500
In-Reply-To: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  1 Feb 2013 19:17:23 +0100

> Do long time in-todo-queue convert of port list netlik messages to multipart
> ones. That was needed in order to reorder calls in team_port_del(). That
> was needed for correct event send of active port zeroing.
> 
> Jiri Pirko (3):
>   team: handle sending port list in the same way option list is sent
>   team: move netlink event notifiers after team_port_leave()
>   team: ab: set active port option as changed when port is leaving

Series applied, thanks.
