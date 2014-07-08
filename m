From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] igmp: fix the problem when mc leave group
Date: Mon, 07 Jul 2014 21:59:46 -0700 (PDT)
Message-ID: <20140707.215946.875639581739785936.davem@davemloft.net>
References: <53B39DB8.2060306@huawei.com>
	<20140707.213132.448071496887411114.davem@davemloft.net>
	<53BB77D4.5000505@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaGHE7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 00:59:47 -0400
In-Reply-To: <53BB77D4.5000505@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 8 Jul 2014 12:47:16 +0800

> Can you queue this patch to stable, this problem is existed in every
> earlier kernel version, and could be triggered easily, I think we
> should fix it for every stable tree.

Done.
