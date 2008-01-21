From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: kill obsolete NET_CLS_POLICE option
Date: Mon, 21 Jan 2008 00:47:57 -0800 (PST)
Message-ID: <20080121.004757.207817354.davem@davemloft.net>
References: <47935F30.9080106@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53514
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757996AbYAUIrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 03:47:52 -0500
In-Reply-To: <47935F30.9080106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 20 Jan 2008 15:48:16 +0100

> [NET_SCHED]: kill obsolete NET_CLS_POLICE option
> 
> The code is already gone for about half a year, the config option
> has been kept around to select the replacement options for easier
> upgrades. This seems long enough, people upgrading from older
> kernels will have to reconfigure a lot anyway.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6.25
