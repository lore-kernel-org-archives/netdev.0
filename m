From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: data of fwmark_reflect needs to be updated
 on netns construction
Date: Thu, 31 Jul 2014 22:09:27 -0700 (PDT)
Message-ID: <20140731.220927.1291287710369710161.davem@davemloft.net>
References: <2a80411c2242306dde7de22d4446717362e082d6.1406809674.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbaHAFJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 01:09:28 -0400
In-Reply-To: <2a80411c2242306dde7de22d4446717362e082d6.1406809674.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 31 Jul 2014 14:34:55 +0200

> Fixes: e110861f86094cd ("net: add a sysctl to reflect the fwmark on replies")
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This doesn't apply cleanly to the 'net' tree, please respin.
