From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: add a missing __percpu pcpu_stats
Date: Wed, 11 Feb 2015 20:04:07 -0800 (PST)
Message-ID: <20150211.200407.1652299594345816297.davem@davemloft.net>
References: <1423713106.4942.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbbBLD5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 22:57:06 -0500
In-Reply-To: <1423713106.4942.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Feb 2015 19:51:46 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Cosmetic patch to add __percpu qualifier to pcpu_stats
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
