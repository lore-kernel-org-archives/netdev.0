From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8169: fix the default setting of rx vlan
Date: Tue, 16 Sep 2014 03:23:05 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB25232A5@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-38-Taiwan-albertk@realtek.com>
 <1394712342-15778-39-Taiwan-albertk@realtek.com>
 <20140912194014.GA15496@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2523183@RTITMBSV03.realtek.com.tw>
 <20140916000321.GA19564@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140916000321.GA19564@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, September 16, 2014 8:03 AM
[...]
> However it's getting messy and the code stomps CPlusCmd in 
> rtl_open right
> before it's given a chance to be read in hw_start. Something like the
> untested patch below should avoid it and keep related things together.

You are right. Your patch is more reasonable. I would sent the patch.
Thanks.
 
Best Regards,
Hayes
