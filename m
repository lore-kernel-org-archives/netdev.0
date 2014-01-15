From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Wed, 15 Jan 2014 13:53:28 -0800 (PST)
Message-ID: <20140115.135328.514671277431781958.davem@davemloft.net>
References: <1389227404-12586-1-git-send-email-thaller@redhat.com>
	<20140110.181030.2081631538801450145.davem@davemloft.net>
	<20140113153110.GA2499@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thaller@redhat.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, stephen@networkplumber.org, dcbw@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887AbaAOVx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 16:53:29 -0500
In-Reply-To: <20140113153110.GA2499@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 13 Jan 2014 16:31:10 +0100

> Sat, Jan 11, 2014 at 12:10:30AM CET, davem@davemloft.net wrote:
>>From: Thomas Haller <thaller@redhat.com>
>>Date: Thu,  9 Jan 2014 01:30:02 +0100
>>
>>> v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
>>> v2 -> v3: reword commit messages, code comments and some refactoring.
>>> v3 -> v4: refactor, rename variables, add enum
>>> 
>>> Thomas Haller (2):
>>>   ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
>>>     IP6 routes
>>>   ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE
>>
>>Series applied, thanks Thomas.
> 
> Hi Dave. Have you pushed this already? I can't see these patches in
> net-next.

Sorry, I must have forgotten to push these changes out before I travelled
on Saturday.

Please respin and resubmit and I'll make sure they get integrated properly.

Thanks.
