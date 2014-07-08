From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] appletalk: fix a coccinella warning in
 net/appletalk/ddp.c
Date: Tue, 08 Jul 2014 14:32:36 -0700 (PDT)
Message-ID: <20140708.143236.99445332079693132.davem@davemloft.net>
References: <53B657EC.6060105@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbaGHVch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 17:32:37 -0400
In-Reply-To: <53B657EC.6060105@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 4 Jul 2014 15:29:48 +0800

> This warning is introduced by commit 7b30600cc6 ("appletalk:
> fix checkpatch error with indent"), So fix it.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
