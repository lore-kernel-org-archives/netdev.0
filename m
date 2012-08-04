From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/4] add support for queue override by setting
 queue_id for port
Date: Fri, 03 Aug 2012 20:41:28 -0700 (PDT)
Message-ID: <20120803.204128.879479288104188554.davem@davemloft.net>
References: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab2HDDl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 23:41:29 -0400
In-Reply-To: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 27 Jul 2012 18:28:51 +0200

> Jiri Pirko (4):
>   netlink: add signed types
>   team: add signed 32-bit team option type
>   team: add per port priority option
>   team: add support for queue override by setting queue_id for port

All applied, thanks.
