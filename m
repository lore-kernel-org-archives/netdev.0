From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] cipso: add __init to cipso_v4_cache_init
Date: Wed, 01 Oct 2014 15:47:27 -0400 (EDT)
Message-ID: <20141001.154727.1004852358839073727.davem@davemloft.net>
References: <1412184603-17294-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbaJATrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:47:31 -0400
In-Reply-To: <1412184603-17294-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 19:30:03 +0200

> cipso_v4_cache_init is only called by __init cipso_v4_init
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
