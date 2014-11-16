From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] reciprocal_div: objects with exported symbols
 should be obj-y rather than lib-y
Date: Sun, 16 Nov 2014 14:19:24 -0500 (EST)
Message-ID: <20141116.141924.8911606977415491.davem@davemloft.net>
References: <85de478df37362b703cb5db64cbfc48d4d4439f5.1415974584.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jim.epost@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482AbaKPTT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 14:19:28 -0500
In-Reply-To: <85de478df37362b703cb5db64cbfc48d4d4439f5.1415974584.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 14 Nov 2014 15:16:47 +0100

> Otherwise the exported symbols might be discarded because of no users
> in vmlinux.
> 
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
