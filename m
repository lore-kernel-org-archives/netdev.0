From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 3/7 RFC] TCPCT part 1c:
 sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
Date: Sat, 21 Nov 2009 11:18:44 -0800 (PST)
Message-ID: <20091121.111844.54272535.davem@davemloft.net>
References: <4B06A8CF.3000303@gmail.com>
	<20091120.092408.208010931.davem@davemloft.net>
	<4B081A81.5000602@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754212AbZKUTS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 14:18:26 -0500
In-Reply-To: <4B081A81.5000602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Sat, 21 Nov 2009 11:51:13 -0500

> This code was based on net/ipv4/tcp_minisocks.c for syncookies.
> Apparently, default for syncookies has been controversial.

I'll have to change that, it doesn't make any sense.  Thanks
for pointing it out.

> Would you accept always default to TCP_COOKIE_MAX?

Sure, let's see what breaks.
