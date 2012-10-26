From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] af_unix.c: fix the compile warning in unix_bind
Date: Thu, 25 Oct 2012 23:16:41 -0400 (EDT)
Message-ID: <20121025.231641.1536209335816707842.davem@davemloft.net>
References: <1351219727-6085-1-git-send-email-windsdaemon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, viro@zeniv.linux.org.uk, xemul@parallels.com,
	netdev@vger.kernel.org
To: windsdaemon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755671Ab2JZDQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 23:16:45 -0400
In-Reply-To: <1351219727-6085-1-git-send-email-windsdaemon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jing Wang <windsdaemon@gmail.com>
Date: Fri, 26 Oct 2012 10:48:47 +0800

> 
> Signed-off-by: Jing Wang <windsdaemon@gmail.com>

What compile warning?  You need to describe what problem
you are solving, rather than assume we can figure it out
by reading your patch.

> -
> +

This doesn't do anything and should be in your patch.
