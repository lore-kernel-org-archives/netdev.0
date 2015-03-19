From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] amd-xgbe: Set DMA mask based on
 hardware register value
Date: Thu, 19 Mar 2015 14:43:24 -0400 (EDT)
Message-ID: <20150319.144324.217714702082923027.davem@davemloft.net>
References: <20150319171301.26446.71081.stgit@tlendack-t1.amdoffice.net>
	<063D6719AE5E284EB5DD2968C1650D6D1CB046B5@AcuExch.aculab.com>
	<550B09F5.8000707@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbCSSn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 14:43:27 -0400
In-Reply-To: <550B09F5.8000707@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 19 Mar 2015 12:40:05 -0500

> Except this version of the hardware can't return a 3

Yep, I've never _ever_ seen HW return garbage in a register.

Nope.

No reason to every program defensively for that.
