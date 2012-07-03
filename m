From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Mon, 02 Jul 2012 22:14:25 -0700 (PDT)
Message-ID: <20120702.221425.418792617776598841.davem@davemloft.net>
References: <eb20e8f67e6aad94c233219e058c3e793ed755cb.1341167171.git.linux@8192.net>
	<18390.1341272010@death.nxdomain>
	<4FF27CA0.7030708@8192.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: linux@8192.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab2GCFO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 01:14:28 -0400
In-Reply-To: <4FF27CA0.7030708@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Eaglesham <linux@8192.net>
Date: Mon, 02 Jul 2012 22:01:20 -0700

> I replaced the mixed tabs and spaces with all tabs when I updated that
> function, but in retrospect the tabs and spaces were likely
> intentional. I will revert.

They were.  Don't change existing coding style unless you are certain
it is wrong.

Besides any such changes are completely outside of the scope of
the changes you are making, so you should have left them out in
any event.
