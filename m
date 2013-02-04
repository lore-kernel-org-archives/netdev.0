From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tcp: ipv6: Update MIB counters for drops
Date: Mon, 04 Feb 2013 13:06:42 -0500 (EST)
Message-ID: <20130204.130642.85750811173100980.davem@davemloft.net>
References: <1359656659-29375-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	niveditasinghvi@gmail.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294Ab3BDSGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:06:44 -0500
In-Reply-To: <1359656659-29375-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Thu, 31 Jan 2013 10:24:19 -0800

> This patch updates LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS in
> tcp_v6_conn_request() and tcp_v6_err(). tcp_v6_conn_request() in particular can
> drop SYNs for various reasons which are not currently tracked.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Applied.
