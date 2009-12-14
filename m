From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 11:16:38 -0800 (PST)
Message-ID: <20091214.111638.165984790.davem@davemloft.net>
References: <4B267708.3010202@gmail.com>
	<1260817033.9141.8.camel@merlyn>
	<20091214.111105.224947761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932489AbZLNTQi@vger.kernel.org>
In-Reply-To: <20091214.111105.224947761.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 14 Dec 2009 11:11:05 -0800 (PST)

> I usually see 2 or 3 three of these bug triggers in the first ten
> minutes after bootup and I haven't seen one yet in 20 minutes
> with the commit reverted.

Nevermind, I take that back, I just got two triggers :-/
