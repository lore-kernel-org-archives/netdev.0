From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/hsr: Fixed version field in ENUM
Date: Wed, 20 Apr 2016 10:51:34 -0400 (EDT)
Message-ID: <20160420.105134.1453680112735393309.davem@davemloft.net>
References: <20160420070829.GA24563@aircraft-controller>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	peter.heise@airbus.com
To: mail@pheise.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095AbcDTOvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 10:51:36 -0400
In-Reply-To: <20160420070829.GA24563@aircraft-controller>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Heise <mail@pheise.de>
Date: Wed, 20 Apr 2016 09:08:29 +0200

> New field (IFLA_HSR_VERSION) was added in the middle of an existing
> ENUM and would break kernel ABI, therefore moved to the end.
> Reported by Stephen Hemminger.
> 
> Signed-off-by: Peter Heise <peter.heise@airbus.com>

Applied, thanks.
