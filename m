From: hayeswang <hayeswang@realtek.com>
Subject: RE: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 25 Jul 2012 10:10:08 +0800
Message-ID: <208C5E31B39C438F831D9578F88CAD71@realtek.com.tw>
References: <A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw><20120720210107.GA28118@electric-eye.fr.zoreil.com><CEE7FFC13FF3495C9771B87B8F199BA7@realtek.com.tw> <20120723.235931.725099984853258732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <romieu@fr.zoreil.com>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60001 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409Ab2GYCKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 22:10:23 -0400
In-Reply-To: <20120723.235931.725099984853258732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 David Miller [mailto:davem@davemloft.net] 
> Sent: Tuesday, July 24, 2012 3:00 PM
> To: Hayeswang
> Cc: romieu@fr.zoreil.com; eric.dumazet@gmail.com; 
> netdev@vger.kernel.org
> Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
> 
[...]
> 
> I still have not seen a good explanation why the chip modifies fields
> in the packet, such as the length, when we ask it only to compute the
> checksum?

I don't know the history and the detail about the bug. I think only our designer
could answer your question. I guess it is a careless mistake.
 
Best Regards,
Hayes
