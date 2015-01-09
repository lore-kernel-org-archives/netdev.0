From: Hau <hau@realtek.com>
Subject: RE: [PATCH net-next 07/11] r8169:update rtl8168f pcie ephy parameter
Date: Fri, 9 Jan 2015 05:18:19 +0000
Message-ID: <80377ECBC5453840BA8C7155328B5377010B9F65@RTITMBSV03.realtek.com.tw>
References: <1420648826-12972-1-git-send-email-hau@realtek.com>
	<1420648826-12972-8-git-send-email-hau@realtek.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC2C99@AcuExch.aculab.com>
 <20150108.200858.548066819871890131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:43471 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbbAIFSj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 00:18:39 -0500
In-Reply-To: <20150108.200858.548066819871890131.davem@davemloft.net>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, January 09, 2015 12:09 PM
> To: David.Laight@ACULAB.COM
> Cc: Hau; netdev@vger.kernel.org; nic_swsd; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next 07/11] r8169:update rtl8168f pcie ephy
> parameter
> 
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Wed, 7 Jan 2015 16:45:58 +0000
> 
> > From: Chunhao Lin
> >> @@ -5852,7 +5852,9 @@ static void rtl_hw_start_8168f_1(struct
> rtl8169_private *tp)
> >>  		{ 0x06, 0x00c0,	0x0020 },
> >>  		{ 0x08, 0x0001,	0x0002 },
> >>  		{ 0x09, 0x0000,	0x0080 },
> >> -		{ 0x19, 0x0000,	0x0224 }
> >> +		{ 0x19, 0x0000,	0x0224 },
> >> +		{ 0x00, 0x0000,	0x0008 },
> >> +		{ 0x0c, 0x3df0,	0x0200 }
> >
> > I can't help feeling these lines all require short comments.
> 
> Agreed.
> 
> And this goes for some of the other patches that look like this too.
>
I will merge the patches and update again.

Thanks.
 
------Please consider the environment before printing this e-mail.
