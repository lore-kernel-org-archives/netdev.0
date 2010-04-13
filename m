From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] packet: support for TX time stamps on RAW sockets
Date: Tue, 13 Apr 2010 01:30:58 -0700 (PDT)
Message-ID: <20100413.013058.202126142.davem@davemloft.net>
References: <20100408084128.GA17098@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40825
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751374Ab0DMIay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:30:54 -0400
In-Reply-To: <20100408084128.GA17098@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 8 Apr 2010 10:41:28 +0200

> Enable the SO_TIMESTAMPING socket infrastructure for raw packet sockets.
> We introduce PACKET_TX_TIMESTAMP for the control message cmsg_type.
> 
> Similar support for UDP and CAN sockets was added in commit
> 51f31cabe3ce5345b51e4a4f82138b38c4d5dc91
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Looks good, applied to net-next-2.6, thanks.
