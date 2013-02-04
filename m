From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tcp: Update MIB counters for drops
Date: Mon, 04 Feb 2013 13:06:35 -0500 (EST)
Message-ID: <20130204.130635.1079021097047335596.davem@davemloft.net>
References: <1359656646-29339-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	niveditasinghvi@gmail.com
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab3BDSGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:06:38 -0500
In-Reply-To: <1359656646-29339-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijay Subramanian <subramanian.vijay@gmail.com>
Date: Thu, 31 Jan 2013 10:24:06 -0800

> This patch updates LINUX_MIB_LISTENDROPS in tcp_v4_conn_request() and
> tcp_v4_err(). tcp_v4_conn_request() in particular can drop SYNs for various
> reasons which are not currently tracked.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Applied.
