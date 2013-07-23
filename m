From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/3] add support for peer notifications and
 igmp rejoins for team
Date: Tue, 23 Jul 2013 16:54:25 -0700 (PDT)
Message-ID: <20130723.165425.1866178315491625952.davem@davemloft.net>
References: <1374315234-7096-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, edumazet@google.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934085Ab3GWXy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 19:54:28 -0400
In-Reply-To: <1374315234-7096-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 20 Jul 2013 12:13:51 +0200

> The middle patch adjusts core infrastructure so the bonding code can be
> generalized and reused by team.
> 
> v1->v2: using msecs_to_jiffies() as suggested by Eric
> 
> Jiri Pirko (3):
>   team: add peer notification
>   net: convert resend IGMP to notifier event
>   team: add support for sending multicast rejoins

Series applied, thanks Jiri.
