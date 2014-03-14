From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v3 1/2] r8152: addRTL8152_EARLY_AGG_TIMEOUT_SUPER
Date: Fri, 14 Mar 2014 10:37:21 +0800
Message-ID: <A56A13416A724183888BB62CEFD2B817@realtek.com.tw>
References: <1394712342-15778-1-Taiwan-albertk@realtek.com><1394712342-15778-2-Taiwan-albertk@realtek.com><063D6719AE5E284EB5DD2968C1650D6D0F6DCB6E@AcuExch.aculab.com> <20140313.132222.536931544768069240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>, <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140313.132222.536931544768069240.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From: David Miller [mailto:davem@davemloft.net] 
 Sent: Friday, March 14, 2014 1:22 AM
[...]
> And I fundamentally disagree with this being a Kconfig parameter.
> 
> Make it run-time calculated _or_ settable via ethtool.

Excuse me. How should I make it run-time calculated without a
Kconfig parameter? Should I use module_param? 

Best Regards,
Hayes
