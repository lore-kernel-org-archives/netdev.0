From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: net-next kernel NULL pointer dereference at fib_rules_tclass
Date: Wed, 11 Jul 2012 10:42:09 +0300
Message-ID: <4FFD2E51.9060200@mellanox.com>
References: <20120710.094428.1167234955738653678.davem@davemloft.net> <1341941101.3265.5799.camel@edumazet-glaptop> <20120710111434.00003ba8@unknown> <20120710.180543.1460678493453873565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <gregory.v.rose@intel.com>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, <shlomop@mellanox.com>,
	<amirv@mellanox.com>, <erezsh@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:42981 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756735Ab2GKHoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:44:32 -0400
In-Reply-To: <20120710.180543.1460678493453873565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/2012 4:05 AM, David Miller wrote:
> Great, pushed out to net-next, thanks everyone.

works here too, no crashing any more (on that one...)

Or.
