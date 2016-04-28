From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ps3_gelic: fix memcpy parameter
Date: Thu, 28 Apr 2016 16:38:15 -0400 (EDT)
Message-ID: <20160428.163815.1737125177217196446.davem@davemloft.net>
References: <1461638023-2986-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbcD1UiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:38:17 -0400
In-Reply-To: <1461638023-2986-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Tue, 26 Apr 2016 04:33:43 +0200

> The size allocated for target->hwinfo and the number of bytes copied in it
> should be consistent.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Applied, thanks.
