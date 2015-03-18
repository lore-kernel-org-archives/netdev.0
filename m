From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/3] Add max rate TXQ attribute
Date: Wed, 18 Mar 2015 14:57:57 -0400 (EDT)
Message-ID: <20150318.145757.1969543543208545499.davem@davemloft.net>
References: <1426683455-24243-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36921 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbbCRS6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 14:58:00 -0400
In-Reply-To: <1426683455-24243-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 18 Mar 2015 14:57:32 +0200

> Add the ability to set a max-rate limitation for TX queues.
> The attribute name is maxrate and the units are Mbs, to make
> it similar to the existing max-rate limitation knobs (ETS and 
> SRIOV ndo calls).

Series applied, thanks.
