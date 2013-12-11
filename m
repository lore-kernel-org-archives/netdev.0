From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v7 0/2] net: sched: fix two issues
Date: Wed, 11 Dec 2013 14:20:32 -0500 (EST)
Message-ID: <20131211.142032.645385003264171429.davem@davemloft.net>
References: <1386658768-29584-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3LKTUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:20:39 -0500
In-Reply-To: <1386658768-29584-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Tue, 10 Dec 2013 14:59:26 +0800

> fix calculation of max_size in tbf
> fix quantum calculation introduced by 64bit rates.

Eric does this series look good to you now?

Thanks.
