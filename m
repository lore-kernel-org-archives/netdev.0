From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] add stealth mode
Date: Wed, 23 Sep 2015 11:15:50 -0700 (PDT)
Message-ID: <20150923.111550.2244251359054285055.davem@davemloft.net>
References: <1442397259-28894-1-git-send-email-matteo@openwrt.org>
	<20150916110629.GP24810@breakpoint.cc>
	<CAFnufp2cyZhfy7GRbP1r7xStm4mMdcHKeXmtLDXU1=UfVxtZjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: matteo@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbbIWSPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:15:51 -0400
In-Reply-To: <CAFnufp2cyZhfy7GRbP1r7xStm4mMdcHKeXmtLDXU1=UfVxtZjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matteo Croce <matteo@openwrt.org>
Date: Wed, 23 Sep 2015 18:36:12 +0200

> The point is to do the filtering without *tables at all,
> like /proc/sys/net/ipv4/icmp_echo_ignore_all does for pings

That's not a good argument, sorry.
