From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] net: rename device's sysfs symlinks on
 name change
Date: Wed, 15 Jan 2014 15:17:56 -0800 (PST)
Message-ID: <20140115.151756.893975066531781247.davem@davemloft.net>
References: <1389733131-15390-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com,
	edumazet@google.com, nicolas.dichtel@6wind.com, amwang@redhat.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaAOXR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:17:57 -0500
In-Reply-To: <1389733131-15390-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 14 Jan 2014 21:58:49 +0100

> First patch only adds helper functions and cleans up the code a bit, second
> one already does the renaming.
> 
> v1->v2:
> Don't export the function, as it's used only in dev.c.
> 
> Reported-by: Ding Tianhong <dingtianhong@huawei.com>
> CC: Ding Tianhong <dingtianhong@huawei.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> CC: Cong Wang <amwang@redhat.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Series applied, thanks Vaeceslav.
