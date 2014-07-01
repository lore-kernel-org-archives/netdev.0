From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] ipv6: Add more debugging around accept-ra logic.
Date: Tue, 01 Jul 2014 12:16:36 -0700 (PDT)
Message-ID: <20140701.121636.2037098056755566357.davem@davemloft.net>
References: <1403732693-18282-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaGATQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 15:16:37 -0400
In-Reply-To: <1403732693-18282-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed, 25 Jun 2014 14:44:52 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> This is disabled by default, just like similar debug info
> already in this module.  But, makes it easier to find out
> why RA is not being accepted when debugging strange behaviour.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied.
