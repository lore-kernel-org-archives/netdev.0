From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] Restore UFO support to virtio_net devices
Date: Mon, 02 Feb 2015 17:49:18 -0800 (PST)
Message-ID: <20150202.174918.1368082761533704490.davem@davemloft.net>
References: <1422889269-16007-1-git-send-email-vyasevic@redhat.com>
	<20150202.131158.2302675247156677150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	mst@redhat.com, ben@decadent.org.uk, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932612AbbBCBtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 20:49:21 -0500
In-Reply-To: <20150202.131158.2302675247156677150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 02 Feb 2015 13:11:58 -0800 (PST)

> Vlad, this still fails the same way.
 ...
> Please build allmodconfig, that is the exact build I use to test your
> and everyone else's changes.

Oh, also, there is trailing whitespace in one of the comments added
by patch #1.  I've been silently fixing it up for you, but since you
have to respin this one more time I'd appreciate it if you're fix
it up in your copy this time. :)

Thanks.
