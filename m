From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 12/12 net-2.6.25] [NETNS]: Add namespace for ICMP
 replying code.
Date: Wed, 23 Jan 2008 18:30:36 +0900 (JST)
Message-ID: <20080123.183036.94528507.yoshfuji@linux-ipv6.org>
References: <1201074387-7366-3-git-send-email-den@openvz.org>
	<20080122.235130.84789113.davem@davemloft.net>
	<1201079789.10778.26.camel@mistigri.inria.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, den@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: mathieu.lacage@sophia.inria.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38789 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbYAWJaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 04:30:20 -0500
In-Reply-To: <1201079789.10778.26.camel@mistigri.inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1201079789.10778.26.camel@mistigri.inria.fr> (at Wed, 23 Jan 2008 10:16:29 +0100), Mathieu Lacage <mathieu.lacage@sophia.inria.fr> says:

> I have been following the netns patches on this ML for a while but I
> still have not figured out in which tree the patches fed to David Miller
> are applied. I have attempted to grep the public trees 'davem/net-2.6'
> and 'davem/net-2.6.25' but without much success so far. Is there a
> public git tree I can clone which contains all the netns patches which
> David Miller state are 'Applied' ?

I'm cloning from
	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git

There may be some time-lag.

--yoshfuji
