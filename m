From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] sctp: do some clean up and fix comments
Date: Mon, 28 Oct 2013 01:02:51 -0400 (EDT)
Message-ID: <20131028.010251.1046743704592075726.davem@davemloft.net>
References: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vyasevich@gmail.com,
	dingtianhong@huawei.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56478 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337Ab3J1FCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 01:02:53 -0400
In-Reply-To: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Sat, 26 Oct 2013 16:06:29 +0800

> This patch series includes some comments fix, merge tow if-statements,
> remove the repeat initialize with 0.
> 
> v1 -> v2:
>   - patch1: combine two comment typos fix patches into one,
>     as suggested by Vlad, and add his ACK.
>   - patch2: add Vlad's ACK.
>   - patch3: line up 2 parts of 'if' statements, as suggested by Vlad.
>     fix some comment typos, as suggested by Sergei.

Applied to net-next, thanks.
