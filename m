From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 414/428] net/ipv6/tcp_ipv6.c:930: warning:
 passing argument 1 of 'tcp_v6_md5_do_lookup' discards qualifiers from
 pointer target type
Date: Tue, 29 Sep 2015 21:12:43 -0700 (PDT)
Message-ID: <20150929.211243.946334552303109593.davem@davemloft.net>
References: <201509301242.V51qs4FL%fengguang.wu@intel.com>
	<1443586228.32531.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, edumazet@google.com, kbuild-all@01.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbI3EMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:12:44 -0400
In-Reply-To: <1443586228.32531.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Sep 2015 21:10:28 -0700

> Thanks, probably a matter of applying this patch.

Looks obvious enough, please submit this formally, thanks.
