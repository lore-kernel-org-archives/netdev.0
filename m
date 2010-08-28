From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: use for_each_set_bit
Date: Sat, 28 Aug 2010 15:37:33 -0700 (PDT)
Message-ID: <20100828.153733.48520643.davem@davemloft.net>
References: <1282972106-9914-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752797Ab0H1WhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:37:17 -0400
In-Reply-To: <1282972106-9914-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 28 Aug 2010 14:08:26 +0900

> Replace open-coded loop with for_each_set_bit().
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org

Applied.
