From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/irda/sh_irda: return to RX mode when TX error
Date: Tue, 18 Jan 2011 16:15:48 -0800 (PST)
Message-ID: <20110118.161548.229732736.davem@davemloft.net>
References: <w3ppqs0ncyp.wl%kuninori.morimoto.gx@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: kuninori.morimoto.gx@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752255Ab1ASAPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 19:15:14 -0500
In-Reply-To: <w3ppqs0ncyp.wl%kuninori.morimoto.gx@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
Date: Fri, 14 Jan 2011 16:47:42 +0900

> sh_irda can not use RX/TX in same time,
> but this driver didn't return to RX mode when TX error occurred.
> This patch care xmit error case to solve this issue.
> 
> Signed-off-by: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>

Applied, thank you.
