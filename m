From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IRDA: irda_create() nuke user triggable printk
Date: Mon, 07 Jan 2008 00:31:13 -0800 (PST)
Message-ID: <20080107.003113.184624968.davem@davemloft.net>
References: <1199666072-1824-1-git-send-email-max@stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: max@stro.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755113AbYAGIbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 03:31:13 -0500
In-Reply-To: <1199666072-1824-1-git-send-email-max@stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: maximilian attems <max@stro.at>
Date: Mon,  7 Jan 2008 01:34:32 +0100

> easy to trigger as user with sfuzz.
> 
> irda_create() is quiet on unknown sock->type,
> match this behaviour for SOCK_DGRAM unknown protocol
> 
> Signed-off-by: maximilian attems <max@stro.at>

Applied, thanks.
