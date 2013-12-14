From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netconf: add proxy-arp support
Date: Sat, 14 Dec 2013 00:58:48 -0500 (EST)
Message-ID: <20131214.005848.389822723125039209.davem@davemloft.net>
References: <20131212130650.52c7b267@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab3LNF6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 00:58:50 -0500
In-Reply-To: <20131212130650.52c7b267@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 12 Dec 2013 13:06:50 -0800

> Add support to netconf to show changes to proxy-arp status on a per
> interface basis via netlink in a manner similar to forwarding
> and reverse path state.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
