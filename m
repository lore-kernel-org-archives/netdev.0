From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8169: disable L23
Date: Wed, 9 Jul 2014 06:36:05 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2505DFA@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-6-Taiwan-albertk@realtek.com>
 <20140708201630.GA31885@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140708201630.GA31885@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Wednesday, July 09, 2014 4:17 AM
> To: Hayes Wang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; nic_swsd
> Subject: Re: [PATCH net] r8169: disable L23
[...]
> Can you elaborate what L23 is or should the commit message be reworded
> as "Disable a (yet undocumented) power saving feature that randomly
> causes RTL8411, RTL8111G, RTL8402, RTL8105, and RTL8106 devices to be
> lost on some systems." ?

The L2/L3 are the link status which are defined in the specification of the PCI
Express Base Specification for the link state power manager. I don't know them
much, so I don't sure if I could explain them clearly. 

Best Regards,
Hayes
