From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] add stealth mode
Date: Wed, 23 Sep 2015 11:16:51 -0700 (PDT)
Message-ID: <20150923.111651.772678418859618283.davem@davemloft.net>
References: <20150916110629.GP24810@breakpoint.cc>
	<CAFnufp2cyZhfy7GRbP1r7xStm4mMdcHKeXmtLDXU1=UfVxtZjQ@mail.gmail.com>
	<1443029392.29850.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matteo@openwrt.org, fw@strlen.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704AbbIWSQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:16:52 -0400
In-Reply-To: <1443029392.29850.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Sep 2015 10:29:52 -0700

> Yes, but this adds code in many places, even for people not caring of
> such protection.
> 
> The point is : people wanting firewall like protections should instead
> use netfilter framework.

+1
