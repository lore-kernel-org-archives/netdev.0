From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Minor ipv6 mcast cleanups
Date: Tue, 20 Aug 2013 23:53:25 -0700 (PDT)
Message-ID: <20130820.235325.202960800450259958.davem@davemloft.net>
References: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52374 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab3HUGx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:53:26 -0400
In-Reply-To: <1376994122-3022-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 20 Aug 2013 12:21:59 +0200

> Daniel Borkmann (3):
>   net: ipv6: igmp6_event_query: use msecs_to_jiffies
>   net: ipv6: minor: *_start_timer: rather use unsigned long
>   net: ipv6: mcast: minor: use defines for rfc3810/8.1 lengths

All applied, thanks Daniel.
