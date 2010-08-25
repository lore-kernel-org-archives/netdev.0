From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: avoid ethtool on non running interface
Date: Wed, 25 Aug 2010 16:39:07 -0700 (PDT)
Message-ID: <20100825.163907.212699668.davem@davemloft.net>
References: <20100824161256.0a6079e7@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59341
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751615Ab0HYXiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:38:51 -0400
In-Reply-To: <20100824161256.0a6079e7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 24 Aug 2010 16:12:56 -0700

> If bridge port is offline, don't call ethtool to query speed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
