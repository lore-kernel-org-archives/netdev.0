From: hayeswang <hayeswang@realtek.com>
Subject: RE: Possible bug with r8169 driver
Date: Mon, 1 Oct 2012 13:51:59 +0800
Message-ID: <262549102A0343EDA34AA0A41217180C@realtek.com.tw>
References: <2197741.c8FeV4Xbis@bureau> <20120927222147.GA29047@electric-eye.fr.zoreil.com> <1478421.GOy9qdQlkG@bureau> <20120929072028.GA3730@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'Nolwenn' <donolwenn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:51940 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab2JAFwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 01:52:11 -0400
In-Reply-To: <20120929072028.GA3730@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Saturday, September 29, 2012 3:20 PM
> To: Nolwenn
> Cc: Hayeswang; netdev@vger.kernel.org
> Subject: Re: Possible bug with r8169 driver
> 
[...]
> 
> [RTL8168f/8111f]
> > > Hayes, is there by any luck something different for the 
> 8168f regarding
> > > the layout of the multicast filtering registers ?
> > 
> > I don't have sufficient skills in networks to understand 
> what do you mean, 
> > sorry. Any command line, files comparing to get the information ?
> 
> The documentation is scarce to say the least. Hayes can tell if some
> register layout change or chipset specifics has gone unnoticed.

I need check it with our hardware engineers. I would reply after getting
response. Could you try to set IO 0x08 ~ 0x0F to 0xff for testing, first?
 
Best Regards,
Hayes
