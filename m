From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net 0/3] team: couple of fixes
Date: Wed, 12 Jun 2013 10:58:40 +0200
Message-ID: <20130612085840.GA1852@minipsycho.brq.redhat.com>
References: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
 <20130612.005724.1355461391911598238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, fbl@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:46646 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755558Ab3FLI6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 04:58:46 -0400
Received: by mail-ee0-f42.google.com with SMTP id c4so4192784eek.15
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 01:58:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130612.005724.1355461391911598238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 12, 2013 at 09:57:24AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sat,  8 Jun 2013 15:00:52 +0200
>
>> Jiri Pirko (3):
>>   team: check return value of team_get_port_by_index_rcu() for NULL
>>   team: move add to port list before port enablement
>>   team: fix checks in team_get_first_port_txable_rcu()
>
>Series applied, thanks Jiri.

Thanks Dave. Please note that this is suitable for stable trees as well.
