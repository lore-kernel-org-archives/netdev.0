From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: make local functions static
Date: Mon, 13 Jan 2014 12:01:00 -0800 (PST)
Message-ID: <20140113.120100.765084542133494360.davem@davemloft.net>
References: <20140109222227.3b3b5776@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbaAMUBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 15:01:01 -0500
In-Reply-To: <20140109222227.3b3b5776@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 9 Jan 2014 22:22:27 -0800

> Avoid needless export of local functions
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
