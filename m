From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/3] team: couple of fixes
Date: Wed, 12 Jun 2013 02:14:54 -0700 (PDT)
Message-ID: <20130612.021454.835293828711213561.davem@davemloft.net>
References: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
	<20130612.005724.1355461391911598238.davem@davemloft.net>
	<20130612085840.GA1852@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, fbl@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274Ab3FLJOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 05:14:55 -0400
In-Reply-To: <20130612085840.GA1852@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 12 Jun 2013 10:58:40 +0200

> Wed, Jun 12, 2013 at 09:57:24AM CEST, davem@davemloft.net wrote:
>>From: Jiri Pirko <jiri@resnulli.us>
>>Date: Sat,  8 Jun 2013 15:00:52 +0200
>>
>>> Jiri Pirko (3):
>>>   team: check return value of team_get_port_by_index_rcu() for NULL
>>>   team: move add to port list before port enablement
>>>   team: fix checks in team_get_first_port_txable_rcu()
>>
>>Series applied, thanks Jiri.
> 
> Thanks Dave. Please note that this is suitable for stable trees as well.

Queued up, thanks for letting me know.
