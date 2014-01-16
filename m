From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/2] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Wed, 15 Jan 2014 17:01:12 -0800 (PST)
Message-ID: <20140115.170112.1340729897073468646.davem@davemloft.net>
References: <20140110.181030.2081631538801450145.davem@davemloft.net>
	<1389796619-13440-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jiri@resnulli.us,
	netdev@vger.kernel.org, stephen@networkplumber.org, dcbw@redhat.com
To: thaller@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbaAPBBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 20:01:14 -0500
In-Reply-To: <1389796619-13440-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Haller <thaller@redhat.com>
Date: Wed, 15 Jan 2014 15:36:57 +0100

> v1 -> v2: add a second commit, handling NOPREFIXROUTE in ip6_del_addr.
> v2 -> v3: reword commit messages, code comments and some refactoring.
> v3 -> v4: refactor, rename variables, add enum
> v4 -> v5: rebase, so that patch applies cleanly to current net-next/master

Applied, sorry for not pushing these out properly last time.
