From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] netconf: rename PROXY_ARP to NEIGH_PROXY
Date: Sun, 22 Dec 2013 18:03:04 -0500 (EST)
Message-ID: <20131222.180304.77986090568057072.davem@davemloft.net>
References: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898Ab3LVXDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:03:06 -0500
In-Reply-To: <20131217223552.60d1f5cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 17 Dec 2013 22:35:52 -0800

> Use same field for both IPv4 (proxy_arp) and IPv6 (proxy_ndp)
> so fix it before API is set to be a common name
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
