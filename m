From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: remove unused macro.
Date: Mon, 29 Apr 2013 14:23:53 -0400 (EDT)
Message-ID: <20130429.142353.132526581831121679.davem@davemloft.net>
References: <1367069950-17137-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758647Ab3D2SXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:23:55 -0400
In-Reply-To: <1367069950-17137-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Sat, 27 Apr 2013 16:39:10 +0300

> This patch removes the IP_ADD_STATS macro from include/net/ip.h as
> it is unused.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

I think this interface does no harm sitting in this header file,
so let's leave it there for now.

Thank you.
