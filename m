From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix flowi6_proto value
Date: Mon, 02 Sep 2013 21:01:18 -0700 (PDT)
Message-ID: <20130902.210118.517392378071402267.davem@davemloft.net>
References: <1378087613-15279-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab3ICDzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 23:55:13 -0400
In-Reply-To: <1378087613-15279-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  2 Sep 2013 10:06:51 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> It should be IPPROTO_UDP.
> 
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
