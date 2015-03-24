From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for kernel 3.4.x 0/1] net: neighbour: Add
 mcast_resolicit to configure the number of multicast resolicitations in
 PROBE state
Date: Tue, 24 Mar 2015 11:59:38 -0400 (EDT)
Message-ID: <20150324.115938.688597808655372422.davem@davemloft.net>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>
	<55114543.2080709@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yanjun.Zhu@windriver.com, lizefan@huawei.com,
	netdev@vger.kernel.org, ulf.samuelsson@ericsson.com,
	yoshfuji@linux-ipv6.org, Alexandre.Dietsch@windriver.com
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932098AbbCXP7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 11:59:40 -0400
In-Reply-To: <55114543.2080709@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Date: Tue, 24 Mar 2015 20:06:43 +0900

> Hmm, it needs additional knob to change this 10+-year-old
> behavior.  I am not for backporting this to old stable
> kernels unless all stable kernels supports this knob as
> well.

It is not appropriate for -stable at all.
