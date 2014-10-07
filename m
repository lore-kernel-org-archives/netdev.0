From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Tue, 07 Oct 2014 16:50:18 -0400 (EDT)
Message-ID: <20141007.165018.929111009463969597.davem@davemloft.net>
References: <20141007.161832.453892039501955243.davem@davemloft.net>
	<20141007203344.GA4748@roeck-us.net>
	<1559212122.19553.1412714971908.open-xchange@webmail.nmp.skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1559212122.19553.1412714971908.open-xchange@webmail.nmp.skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue, 7 Oct 2014 22:49:31 +0200 (CEST)

> Maybe comment should have been "static values are automatically initialized to
> 0" then ?

Yes, that sounds a lot better, please respin.
