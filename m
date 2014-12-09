From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] timestamping updates
Date: Mon, 08 Dec 2014 20:21:29 -0500 (EST)
Message-ID: <20141208.202129.2087061521063011275.davem@davemloft.net>
References: <1417404155-28607-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luto@amacapital.net,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLIBVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:21:32 -0500
In-Reply-To: <1417404155-28607-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Sun, 30 Nov 2014 22:22:32 -0500

> The main goal for this patchset is to allow correlating timestamps
> with the egress interface. Also introduce a warning, as discussed
> previously, and update the tests to verify the new feature.

Series applied, thanks.
