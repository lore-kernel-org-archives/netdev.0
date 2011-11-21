From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix wrong parameter given to sizeof call
Date: Mon, 21 Nov 2011 14:56:50 -0500 (EST)
Message-ID: <20111121.145650.1249420513986533477.davem@davemloft.net>
References: <4EC56FB0.3040900@intra2net.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.jarosch@intra2net.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40319 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab1KUT44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 14:56:56 -0500
In-Reply-To: <4EC56FB0.3040900@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Date: Thu, 17 Nov 2011 21:33:52 +0100

> "remote_list" is of type
> 
> struct dma_chunk remote_list[VETH_MAX_FRAMES_PER_MSG];
> 
> Probably a copy'n'paste error.
> 
> Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>

Applied, thanks.
