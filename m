From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Allow allocating different number RX and TX
 mqs
Date: Mon, 10 Jan 2011 16:06:42 -0800 (PST)
Message-ID: <20110110.160642.146350621.davem@davemloft.net>
References: <alpine.DEB.2.00.1101092123340.3137@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56474
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753800Ab1AKAGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 19:06:10 -0500
In-Reply-To: <alpine.DEB.2.00.1101092123340.3137@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 9 Jan 2011 21:36:25 -0800 (PST)

> Add functions so that a different number of TX and RX queues can be
> allocated in a netdevice.  Second patch modifies mlx4 driver to call
> this function which is an example of a driver that allocates different
> numbers for TX and RX queues.

Both applied, thanks Tom.
