From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] tulip_core.c : out-of-bounds check.
Date: Fri, 13 Mar 2015 12:43:49 -0400 (EDT)
Message-ID: <20150313.124349.1006280192823176579.davem@davemloft.net>
References: <1426256152-5522-1-git-send-email-ameenali023@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ameenali023@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757164AbbCMQnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:43:51 -0400
In-Reply-To: <1426256152-5522-1-git-send-email-ameenali023@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ameen Ali <ameenali023@gmail.com>
Date: Fri, 13 Mar 2015 16:15:52 +0200

> Array index 'j' is used before limits check.
> 
> Suggest put limit check before index use.
> 
> Signed-off-by : <Ameenali023@gmail.com>

Applied, thanks.
