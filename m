From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8152: drop the tx packet with invalid length
Date: Mon, 22 Dec 2014 11:34:44 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ED5B01@RTITMBSV03.realtek.com.tw>
References: <1417020748.29427.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.120658.498602780456343676.davem@davemloft.net>
	 <1417027459.29427.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.153356.461494573591656082.davem@davemloft.net>
	 <0835B3720019904CB8F7AA43166CEEB2ED585A@RTITMBSV03.realtek.com.tw>
	 <1419010603.9773.84.camel@edumazet-glaptop2.roam.corp.google.com>
 <1419012837.9773.85.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Hayes Wang 
> Sent: Monday, December 22, 2014 10:23 AM
> To: 'Eric Dumazet'
> Cc: Tom Herbert; David Miller; netdev@vger.kernel.org; 
> nic_swsd; linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: RE: [PATCH net] r8152: drop the tx packet with invalid length
> 
>  Eric Dumazet [mailto:eric.dumazet@gmail.com] 
> > Sent: Saturday, December 20, 2014 2:14 AM
> [...]
> > Could you try following patch ?
> 
> Thank you. I would test it.

It works for me. Thanks.
 
Best Regards,
Hayes
