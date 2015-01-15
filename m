From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] socket: use iov_length()
Date: Thu, 15 Jan 2015 13:57:40 -0500 (EST)
Message-ID: <20150115.135740.848698034113619611.davem@davemloft.net>
References: <20150114.164528.230093054757243054.davem@davemloft.net>
	<1421314558-4252-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbbAOS5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:57:42 -0500
In-Reply-To: <1421314558-4252-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 15 Jan 2015 10:35:58 +0100

> Better to use available helpers.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
