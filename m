From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] be2net: fix some cmds to use mccq instead
 of mbox
Date: Thu, 17 Sep 2009 10:30:20 -0700 (PDT)
Message-ID: <20090917.103020.207030358.davem@davemloft.net>
References: <20090917044331.GA14568@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755748AbZIQRaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 13:30:03 -0400
In-Reply-To: <20090917044331.GA14568@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Thu, 17 Sep 2009 10:13:31 +0530

> All cmds issued to BE after the creation of mccq must now use the mcc-q
> (and not mbox) to avoid a hw issue that results in mbox poll timeout.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied, thanks.
