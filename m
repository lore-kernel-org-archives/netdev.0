From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 03:24:48 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201054BD8@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
 <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB2010517CE@RTITMBSV03.realtek.com.tw>
 <b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201051D51@RTITMBSV03.realtek.com.tw>
 <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord [mailto:mlord@pobox.com]
> Sent: Thursday, November 24, 2016 3:30 AM
[...]
> Worth repeating: other dongles we have tried, eg. those using the asix driver,
> do not cause us any troubles here.  Only the r8152 dongles do.

I couldn't tell you why you would see the problem. I have tested the
RTL8152 on raspberry pi platform with iperf more than 17 hours. And
I don't see any invalid rx descriptor. I don't think it really is the
issue about our hw.

Best Regards,
Hayes
