From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] net: support multiple independant multicast
 routing instances
Date: Tue, 13 Apr 2010 14:51:32 -0700 (PDT)
Message-ID: <20100413.145132.86961768.davem@davemloft.net>
References: <1271171003-11901-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58445
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752246Ab0DMVv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 17:51:28 -0400
In-Reply-To: <1271171003-11901-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 13 Apr 2010 17:03:14 +0200

> this is an updated patchset of my patches to support multiple independant
> multicast routing instances. Changes since the last posting are:
> 
> - rebase to the current net-next-2.6.git tree
> - fix up patch subjects to consistently refer to "ipv4: ipmr:"
> - fix up list_head conversion patch to add new elements at the head of
>   the list instead of at the tail
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/ipmr-2.6.git master

I applied the patches instead of pulling just to check your email
patch submission format, and it was perfect! :-)

I'll do a git pull next time.

All applied to net-next-2.6, thanks!
