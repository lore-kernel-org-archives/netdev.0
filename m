From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 0/3] r8152: configuration setting
Date: Thu, 8 Sep 2016 03:00:57 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2010259F0@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
 <20160907.173746.787161029125318872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160907.173746.787161029125318872.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, September 08, 2016 8:38 AM
[...]
> By forcing a certain mode via a Kconfig value, you are basically making it
> impossible for distributions to do something reasonable here.

The request is always from some manufacturers, not end users.
They always ask the driver to control everything. And I don't
think the end user knows or cares about how the device is set.
That is why I try to satisfy them via Kconfig.

I think you have rejected this way. I would think if there
is any other method. Thanks.

Best Regards,
Hayes
