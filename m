From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-tcp: Replace time wait bucket msg by counter
Date: Wed, 08 Dec 2010 12:16:45 -0800 (PST)
Message-ID: <20101208.121645.229741119.davem@davemloft.net>
References: <alpine.DEB.2.00.1012081139180.2652@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45463
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753397Ab0LHUQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:16:18 -0500
In-Reply-To: <alpine.DEB.2.00.1012081139180.2652@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 8 Dec 2010 11:42:38 -0800 (PST)

> Rather than printing the message to the log, use a mib counter to keep
> track of the count of occurences of time wait bucket overflow.  Reduces
> spam in logs.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
