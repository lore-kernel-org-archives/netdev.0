From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: enable GRO by default
Date: Wed, 15 Sep 2010 22:29:41 -0700 (PDT)
Message-ID: <20100915.222941.63035178.davem@davemloft.net>
References: <20100915202217.365fee46@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752158Ab0IPF3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 01:29:22 -0400
In-Reply-To: <20100915202217.365fee46@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 15 Sep 2010 20:22:17 -0700

> The driver has supported GRO for a while, but it was not enabled
> by default.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
