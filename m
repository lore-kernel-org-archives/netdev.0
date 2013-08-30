From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Remove redundant sk variable
Date: Fri, 30 Aug 2013 17:19:21 -0400 (EDT)
Message-ID: <20130830.171921.131288603589376659.davem@davemloft.net>
References: <71fe125646ec6160be05138696d312c050e8b813.1377684285.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769Ab3H3VTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:19:24 -0400
In-Reply-To: <71fe125646ec6160be05138696d312c050e8b813.1377684285.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 28 Aug 2013 12:05:38 +0200

> A sk variable initialized to ndisc_sk is already available outside
> of the branch.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
