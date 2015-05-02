From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] ipv6: Stop /128 route from disappearing
 after pmtu update
Date: Fri, 01 May 2015 21:01:30 -0400 (EDT)
Message-ID: <20150501.210130.1160422268823583419.davem@davemloft.net>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	steffen.klassert@secunet.com, yangyingliang@huawei.com,
	shengyong1@huawei.com, Kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbEBBBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 21:01:34 -0400
In-Reply-To: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 28 Apr 2015 13:03:02 -0700

> The series is separated from another patch series,
> 'ipv6: Only create RTF_CACHE route after encountering pmtu exception',
> which can be found here:

Looks good, and the divorce of inetpeer from ipv6 routes is
especially nice to see.

Series applied, thanks Martin!
