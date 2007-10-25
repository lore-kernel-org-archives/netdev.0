From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [Bugme-new] [Bug 9224] New: Settings to
 /proc/sys/net/ipv[46]/conf/all are not propagated
Date: Fri, 26 Oct 2007 02:14:11 +0900 (JST)
Message-ID: <20071026.021411.108341868.yoshfuji@linux-ipv6.org>
References: <bug-9224-10286@http.bugzilla.kernel.org/>
	<20071025091652.0d7002c1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	svdb+linux-kernel-bugs@stack.nl, yoshfuji@linux-ipv6.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36575 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbXJYROI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 13:14:08 -0400
In-Reply-To: <20071025091652.0d7002c1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20071025091652.0d7002c1.akpm@linux-foundation.org> (at Thu, 25 Oct 2007 09:16:52 -0700), Andrew Morton <akpm@linux-foundation.org> says:

> > Most recent kernel where this bug did not occur: 2.6.22 (not sure)

> Apparently a regression.

I would say it is a bug, but it is not a regression.
I mean, I believe this "bug" lives since 2.2.

--yoshfuji
