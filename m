From: David Miller <davem@davemloft.net>
Subject: Re: [AF_KEY]: Fix skb leak on pfkey_send_migrate() error
Date: Sun, 20 Jan 2008 17:24:39 -0800 (PST)
Message-ID: <20080120.172439.70017380.davem@davemloft.net>
References: <479364DC.40604@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756502AbYAUBYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 20:24:34 -0500
In-Reply-To: <479364DC.40604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 20 Jan 2008 16:12:28 +0100

> commit 4dd3440faa345731c27337ee041c0e9abf2b70dc
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Sun Jan 20 16:10:04 2008 +0100
> 
>     [AF_KEY]: Fix skb leak on pfkey_send_migrate() error
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
