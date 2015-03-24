From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for kernel 3.4.x 1/1] net: neighbour: Add
 mcast_resolicit to configure the number of multicast resolicitations in
 PROBE state
Date: Tue, 24 Mar 2015 11:55:51 -0400 (EDT)
Message-ID: <20150324.115551.2097254629095935718.davem@davemloft.net>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>
	<1427190355-1216-2-git-send-email-Yanjun.Zhu@windriver.com>
	<E66F6C44A7A6EA49ABFC80EA526506DF6A474235@ALA-MBA.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lizefan@huawei.com, netdev@vger.kernel.org,
	ulf.samuelsson@ericsson.com, hideaki.yoshifuji@miraclelinux.com,
	yoshfuji@linux-ipv6.org, Alexandre.Dietsch@windriver.com
To: Yanjun.Zhu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbbCXPzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 11:55:54 -0400
In-Reply-To: <E66F6C44A7A6EA49ABFC80EA526506DF6A474235@ALA-MBA.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zhu, Yanjun" <Yanjun.Zhu@windriver.com>
Date: Tue, 24 Mar 2015 09:51:56 +0000

> This patch is needed in linux kernel 3.4.106. I made a new patch
> based on linux kernel 3.4.106. Please let me know your advice.

It's a new feature therefore not appropriate for -stable.

It's only "needed" from your perspective, therefore you can apply it
to your own local sources as needed.
