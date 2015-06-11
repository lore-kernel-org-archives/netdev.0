From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/2] tcp: export tcp_enter_cwr()
Date: Thu, 11 Jun 2015 00:09:24 -0700 (PDT)
Message-ID: <20150611.000924.653777799068188051.davem@davemloft.net>
References: <1433956097-6186-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	stephen@networkplumber.org, ncardwell@google.com,
	davihay@ifi.uio.no, apetlund@simula.no, dave.taht@bufferbloat.net,
	nicolas.kuhn@telecom-bretagne.eu
To: kennetkl@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbbFKHJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:09:25 -0400
In-Reply-To: <1433956097-6186-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Date: Wed, 10 Jun 2015 19:08:16 +0200

> Upcoming tcp_cdg uses tcp_enter_cwr() to initiate PRR. Export this
> function so that CDG can be compiled as a module.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: David Hayes <davihay@ifi.uio.no>
> Cc: Andreas Petlund <apetlund@simula.no>
> Cc: Dave Taht <dave.taht@bufferbloat.net>
> Cc: Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>

Applied.
