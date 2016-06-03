From: David Miller <davem@davemloft.net>
Subject: Re: Possible problem with e6afc8ac ("udp: remove headers from UDP
 packets before queueing")
Date: Thu, 02 Jun 2016 21:23:40 -0700 (PDT)
Message-ID: <20160602.212340.551938578461360246.davem@davemloft.net>
References: <1464904363.5939.185.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160602.183151.2030076167275348260.davem@davemloft.net>
	<1464922706.5939.186.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com, samanthakumar@google.com,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, sds@tycho.nsa.gov
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbcFCEXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 00:23:42 -0400
In-Reply-To: <1464922706.5939.186.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Jun 2016 19:58:26 -0700

> Arg, I totally messed up the patch title :(

I noticed it was odd, but it's not a big deal.
