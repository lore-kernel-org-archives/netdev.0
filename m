From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: tcp: fix endianness annotation in
 tcp_v6_send_response
Date: Tue, 14 Jun 2016 15:26:00 -0400 (EDT)
Message-ID: <20160614.152600.1867500585341480419.davem@davemloft.net>
References: <1465670498-23896-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florent.fourcot@enst-bretagne.fr
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcFNT0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:26:01 -0400
In-Reply-To: <1465670498-23896-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 11 Jun 2016 20:41:38 +0200

> Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> Fixes: 1d13a96c74fc ("ipv6: tcp: fix flowlabel value in ACK messages send from TIME_WAIT")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
