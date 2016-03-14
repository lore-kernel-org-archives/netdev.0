From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mISDN: Support DR6 indication in mISDNipac driver
Date: Mon, 14 Mar 2016 15:51:52 -0400 (EDT)
Message-ID: <20160314.155152.105722744100552920.davem@davemloft.net>
References: <56E4A3EB.4050507@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mail@maciej.szmigiero.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755505AbcCNTvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:51:55 -0400
In-Reply-To: <56E4A3EB.4050507@maciej.szmigiero.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Date: Sun, 13 Mar 2016 00:19:07 +0100

> According to figure 39 in PEB3086 data sheet, version 1.4 this indication
> replaces DR when layer 1 transition source state is F6.
> 
> This fixes mISDN layer 1 getting stuck in F6 state in TE mode on
> Dialogic Diva 2.02 card (and possibly others) when NT deactivates it.
> 
> Signed-off-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>

Applied.
