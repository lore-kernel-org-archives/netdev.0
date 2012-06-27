From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: Add socket early demux support
Date: Tue, 26 Jun 2012 20:59:40 -0700 (PDT)
Message-ID: <20120626.205940.446485160379675381.davem@davemloft.net>
References: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com>
	<20120626.143401.445148198931339546.davem@davemloft.net>
	<CABa6K_G1+7xvPkveRWEWCpAJcf8gK4=zKwXGtOxJLW2wTCCvMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab2F0D7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 23:59:45 -0400
In-Reply-To: <CABa6K_G1+7xvPkveRWEWCpAJcf8gK4=zKwXGtOxJLW2wTCCvMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 27 Jun 2012 10:29:19 +0800

> How about implementing the whole early demux infrastructure on
> iptables/netfilter like rpfilter and TPROXY, then users have more
> controls.

Sorry, no.
