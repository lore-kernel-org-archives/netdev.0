From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6.26] [IPV6] MROUTE: Support multicast routing.
Date: Thu, 03 Apr 2008 16:31:44 +0900 (JST)
Message-ID: <20080403.163144.18289606.yoshfuji@linux-ipv6.org>
References: <147a89290804022314w7968fd47y7de78a9e87c2d289@mail.gmail.com>
	<20080403.152341.59206559.yoshfuji@linux-ipv6.org>
	<147a89290804030016x7fc67a6bg56af8ed329c6a544@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: johnsonzjo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60268 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759256AbYDCHaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 03:30:08 -0400
In-Reply-To: <147a89290804030016x7fc67a6bg56af8ed329c6a544@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <147a89290804030016x7fc67a6bg56af8ed329c6a544@mail.gmail.com> (at Thu, 3 Apr 2008 10:16:41 +0300), "Andy Johnson" <johnsonzjo@gmail.com> says:

> Do we have to replace some user space headers so that mcast tools will
> compile successfully ?

Thanks for the report.
Not all can be built and pim6sd is the main target so far.

--yoshfuji
