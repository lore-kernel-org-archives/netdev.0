From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: make start_xmit local
Date: Sat, 28 Dec 2013 01:21:18 -0500 (EST)
Message-ID: <20131228.012118.1045178641725841100.davem@davemloft.net>
References: <20131227120646.52138f4b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab3L1GVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:21:20 -0500
In-Reply-To: <20131227120646.52138f4b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 27 Dec 2013 12:06:46 -0800

> Only used in one file, no need to expose
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
