From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add IPV6_HDRINCL option for raw sockets
Date: Thu, 17 Dec 2015 15:12:43 -0500 (EST)
Message-ID: <20151217.151243.1359682670479159843.davem@davemloft.net>
References: <1450282967-3184-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083AbbLQUMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:12:44 -0500
In-Reply-To: <1450282967-3184-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 16 Dec 2015 17:22:47 +0100

> Same as in Windows, we miss IPV6_HDRINCL for SOL_IPV6 and SOL_RAW.
> The SOL_IP/IP_HDRINCL is not available for IPv6 sockets.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This looks fine, applied, thanks!
