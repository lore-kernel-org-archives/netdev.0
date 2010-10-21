From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] napi: unexport napi_reuse_skb
Date: Thu, 21 Oct 2010 04:31:47 -0700 (PDT)
Message-ID: <20101021.043147.232908016.davem@davemloft.net>
References: <20101019101210.1bcff4af@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757581Ab0JULbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:31:25 -0400
In-Reply-To: <20101019101210.1bcff4af@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 19 Oct 2010 10:12:10 -0700

> The function napi_reuse_skb is only used inside core.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
