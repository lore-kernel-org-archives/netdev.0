From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Fri, 10 Jan 2014 18:10:30 -0500 (EST)
Message-ID: <20140110.181030.2081631538801450145.davem@davemloft.net>
References: <20140108200019.GK9007@order.stressinduktion.org>
	<1389227404-12586-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jiri@resnulli.us,
	netdev@vger.kernel.org, stephen@networkplumber.org, dcbw@redhat.com
To: thaller@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758202AbaAJXKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 18:10:32 -0500
In-Reply-To: <1389227404-12586-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Haller <thaller@redhat.com>
Date: Thu,  9 Jan 2014 01:30:02 +0100

> v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
> v2 -> v3: reword commit messages, code comments and some refactoring.
> v3 -> v4: refactor, rename variables, add enum
> 
> Thomas Haller (2):
>   ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to suppress creation of
>     IP6 routes
>   ipv6 addrconf: don't cleanup prefix route for IFA_F_NOPREFIXROUTE

Series applied, thanks Thomas.
