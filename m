From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v4 2/3] TCPCT part 1b:
 sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS, functions
Date: Mon, 02 Nov 2009 02:51:50 -0800 (PST)
Message-ID: <20091102.025150.73299764.davem@davemloft.net>
References: <4AE6E529.706@gmail.com>
	<4AEDDDF3.3070102@gmail.com>
	<4AEEB842.1070705@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55755
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754430AbZKBKvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 05:51:25 -0500
In-Reply-To: <4AEEB842.1070705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Mon, 02 Nov 2009 05:45:22 -0500

> Is that a problem?

Yes, it is a problem.

You can allocate the bit when you add the feature.
