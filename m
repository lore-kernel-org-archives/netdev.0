From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next 0/2] Add two new flags to bridge.
Date: Tue, 30 Apr 2013 15:12:12 -0400 (EDT)
Message-ID: <20130430.151212.196427351152373468.davem@davemloft.net>
References: <1367345928-31135-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	mst@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933490Ab3D3TMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:12:14 -0400
In-Reply-To: <1367345928-31135-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 30 Apr 2013 14:18:45 -0400

> The following series adds 2 new flags to bridge.  One flag allows
> the user to control whether mac learning is performed on the interface
> or not.  By default mac learning is on.
> The other flag allows the user to control whether unicast traffic
> is flooded (send without an fdb) to a given unicast port.  Default is
> on.

As per:

	http://marc.info/?l=linux-netdev&m=136730964130303&w=2

It is absolutely, positively, not appropriate to submit new features
at this time.

If I can make my announcements more intelligable to you, please let me
know how.
