From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] macvtap: locking and offload control
Date: Tue, 25 Jun 2013 16:45:49 -0700 (PDT)
Message-ID: <20130625.164549.2077627185296168562.davem@davemloft.net>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, eric.dumazet@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35156 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab3FYXpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:45:51 -0400
In-Reply-To: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 25 Jun 2013 16:04:18 -0400

> This series of patches changes the macvtap locking to use rtnl instead
> of a private lock and adds the ability for user to specify TAP offload
> features.

Series applied, thanks Vlad.
