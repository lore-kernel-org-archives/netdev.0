From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 06/10] {NET,IB}/mlx4: Add device managed flow
 steering firmware API
Date: Mon, 2 Jul 2012 16:00:21 +0300
Message-ID: <4FF19B65.9080502@mellanox.com>
References: <4FF153F0.8080707@mellanox.com> <CAG4TOxNyxP8FpzNdMZR3WMvFCQtEx_r3oLh6s7sZOcBnqN=6tA@mail.gmail.com> <4FF15BA2.5000104@mellanox.com> <20120702.013626.13785263551119133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roland@kernel.org>, <yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, <hadarh@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:45811 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750793Ab2GBNF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 09:05:27 -0400
In-Reply-To: <20120702.013626.13785263551119133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2012 11:36 AM, David Miller wrote:
> So you must create a real generic interface that other chipsets in similar situations can hook into as well.

OK, understood.

We will remove the module param from the patch set, such that at this point
of submission,  there's no run time setting for the flow steering hash 
function.

Or.
