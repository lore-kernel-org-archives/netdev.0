From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] esp: correct offset for ESN when using NAT-T
Date: Tue, 14 Jun 2016 17:12:57 -0400 (EDT)
Message-ID: <20160614.171257.1045774169463482331.davem@davemloft.net>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
	<20160612234814.15460-2-blair.steven@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: blair.steven@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121AbcFNVPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:15:15 -0400
In-Reply-To: <20160612234814.15460-2-blair.steven@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Blair Steven <blair.steven@alliedtelesis.co.nz>
Date: Mon, 13 Jun 2016 11:48:14 +1200

> The offset for calculating ESN was not taking into account the new UDP
> header created for NAT-T.

All submissions must include a proper signoff.
