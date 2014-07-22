From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/3] net: sctp: Rename
 SCTP_XMIT_NAGLE_DELAY to SCTP_XMIT_DELAY
Date: Tue, 22 Jul 2014 13:32:57 -0700 (PDT)
Message-ID: <20140722.133257.1649397778107446356.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF03@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756647AbaGVUc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 16:32:58 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727AF03@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 22 Jul 2014 08:59:14 +0000

> MSG_MORE and 'corking' a socket would require that the transmit of
> a data chunk be delayed.
> Rename the return value to be less specific.
> 
> Signed-off-by: David Laight <david.laight@aculab.com>
> ---
> 
> Resend with corrected subject line.
> 
> No change from v2.

Applied.
