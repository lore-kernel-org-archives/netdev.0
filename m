From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] bridge: add some comments for NETDEV_RELEASE
Date: Mon, 06 Aug 2012 13:50:03 -0700 (PDT)
Message-ID: <20120806.135003.442648448779232464.davem@davemloft.net>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
	<1344263012-4031-8-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756604Ab2HFUuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:50:04 -0400
In-Reply-To: <1344263012-4031-8-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  6 Aug 2012 22:23:31 +0800

> +	/*
> +	 * We don't notify NETDEV_RELEASE event, as this will
> +	 * stop netconsole on the bridge.
> +	 */

Please format comments in the networking:

	/* Like
	 * this.
	 */

Thanks.
