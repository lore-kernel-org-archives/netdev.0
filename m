From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] core: Correct an over-stringent device loop detection.
Date: Mon, 04 May 2015 16:22:42 -0400 (EDT)
Message-ID: <20150504.162242.880803984197847716.davem@davemloft.net>
References: <1430616824-9006-1-git-send-email-vyasevic@redhat.com>
	<20150504.145815.2274500932397440771.davem@davemloft.net>
	<5547CEC4.3060204@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org, jpirko@redhat.com,
	vfalico@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbbEDUWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 16:22:45 -0400
In-Reply-To: <5547CEC4.3060204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 04 May 2015 15:55:48 -0400

> Can you also queue it for stable.  This has been broken for a while.

Done.
