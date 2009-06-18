From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] sky2: turn off pause during shutdown
Date: Wed, 17 Jun 2009 18:50:30 -0700 (PDT)
Message-ID: <20090617.185030.181079465.davem@davemloft.net>
References: <20090617173031.703636683@vyatta.com>
	<20090617173139.536423149@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752041AbZFRBu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:50:27 -0400
In-Reply-To: <20090617173139.536423149@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 10:30:32 -0700

> This unblocks the chip if it is stuck in pause cycle during
> shutdown.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
