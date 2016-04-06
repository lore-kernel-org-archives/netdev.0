From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add the AF_KCM entries to family name
 tables
Date: Wed, 06 Apr 2016 16:59:39 -0400 (EDT)
Message-ID: <20160406.165939.2239653335603964561.davem@davemloft.net>
References: <1459867271-14592-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: decui@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbcDFU7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:59:41 -0400
In-Reply-To: <1459867271-14592-1-git-send-email-decui@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dexuan Cui <decui@microsoft.com>
Date: Tue,  5 Apr 2016 07:41:11 -0700

> This is for the recent kcm driver, which introduces AF_KCM(41) in
> b7ac4eb(kcm: Kernel Connection Multiplexor module).
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: Signed-off-by: Tom Herbert <tom@herbertland.com>

As this is a bug fix actually, applied to 'net'.
