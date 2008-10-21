From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: skb recycling
Date: Mon, 20 Oct 2008 22:18:57 -0700 (PDT)
Message-ID: <20081020.221857.209830018.davem@davemloft.net>
References: <20081020190922.7dd6510a@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751792AbYJUFTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 01:19:20 -0400
In-Reply-To: <20081020190922.7dd6510a@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 20 Oct 2008 19:09:22 -0700

> Add support for recycling tx buffers into receive buffers.
> This is experimental at this point.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Experimental, but do you have any performance data at all?
Just curious...
