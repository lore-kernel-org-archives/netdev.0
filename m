From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fix accidental creation of sysfs
 directory
Date: Sun, 17 Apr 2011 17:53:03 -0700 (PDT)
Message-ID: <20110417.175303.25129578.davem@davemloft.net>
References: <20110416090915.2594a78e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753534Ab1DRAxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:53:38 -0400
In-Reply-To: <20110416090915.2594a78e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 16 Apr 2011 09:09:15 -0700

> Commit bb900b27a2f49b37bc38c08e656ea13048fee13b introduced a bug in net-next
> because of a typo in notifier. Every device would have the sysfs
> bridge directory (and files). 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
