From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: fix locking comment
Date: Wed, 25 Aug 2010 16:39:01 -0700 (PDT)
Message-ID: <20100825.163901.200385101.davem@davemloft.net>
References: <20100824160810.2fd5007c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59336
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753901Ab0HYXip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:38:45 -0400
In-Reply-To: <20100824160810.2fd5007c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 24 Aug 2010 16:08:10 -0700

> The carrier check is not called from work queue in current code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
