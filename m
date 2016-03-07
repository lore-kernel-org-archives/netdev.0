From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] jme: Do not enable NIC WoL functions on S0
Date: Mon, 07 Mar 2016 15:39:56 -0500 (EST)
Message-ID: <20160307.153956.2097066502892935206.davem@davemloft.net>
References: <1457136716-7251-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, diego.viola@gmail.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbcCGUj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:39:58 -0500
In-Reply-To: <1457136716-7251-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: cooldavid@cooldavid.org
Date: Sat,  5 Mar 2016 08:11:55 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> Otherwise it might be back on resume right after going to suspend in
> some hardware.
> 
> Reported-by: Diego Viola <diego.viola@gmail.com>
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
