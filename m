From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] netconf: add support for IPv6 proxy_ndp
Date: Sun, 22 Dec 2013 18:03:10 -0500 (EST)
Message-ID: <20131222.180310.1276667426299774890.davem@davemloft.net>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
	<20131217223714.325c0e78@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53111 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab3LVXDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:03:11 -0500
In-Reply-To: <20131217223714.325c0e78@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 17 Dec 2013 22:37:14 -0800

> Need to be able to see changes to proxy NDP status on a per
> interface basis via netlink (analog to proxy_arp).
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
