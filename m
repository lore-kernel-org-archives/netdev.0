From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mrp: make mrp_rcv static
Date: Mon, 11 Feb 2013 14:18:27 -0500 (EST)
Message-ID: <20130211.141827.1781037011859336886.davem@davemloft.net>
References: <20130211082524.5fb3a976@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.ward@ll.mit.edu, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759270Ab3BKTSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 14:18:30 -0500
In-Reply-To: <20130211082524.5fb3a976@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 11 Feb 2013 08:25:24 -0800

> Sparse spotted local function that could be static.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
