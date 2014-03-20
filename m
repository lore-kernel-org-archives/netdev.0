From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] af_ieee802154: fix check on broadcast
 address
Date: Thu, 20 Mar 2014 17:20:30 -0400 (EDT)
Message-ID: <20140320.172030.1849954665582219336.davem@davemloft.net>
References: <1395323823-20970-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de, jlu@pengutronix.de
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759339AbaCTVUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 17:20:33 -0400
In-Reply-To: <1395323823-20970-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Thu, 20 Mar 2014 14:57:02 +0100

> This patch fixes an issue which was introduced by commit
> (b70ab2e87f17176d18f67ef331064441a032b5f3).

The canonical way to refer to commits is:

$SHA1_ID ("Commit message header line.")

I've fixed this up for you this time.

> The correct behaviour should be a check on the broadcast address field
> which is 0xffff.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> Reported-by: Jan Luebbe <jlu@pengutronix.de>

Applied, thanks.
