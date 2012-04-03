From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Mon, 02 Apr 2012 22:23:00 -0400 (EDT)
Message-ID: <20120402.222300.1137842205135530387.davem@davemloft.net>
References: <1333417997.18626.1.camel@edumazet-glaptop>
	<20120402.215911.1929019308299701014.davem@davemloft.net>
	<1333419304.18626.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: remi@remlab.net, levinsasha928@gmail.com,
	remi.denis-courmont@nokia.com, davej@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333419304.18626.5.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Apr 2012 04:15:04 +0200

> Any idea of a representative benchmark in dgram af_unix ?

Maybe you could try to make bw_unix from lmbench use
SOCK_DGRAM? :-)
