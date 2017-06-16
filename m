From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v2 0/2] r8152: adjust runtime suspend/resume
Date: Fri, 16 Jun 2017 03:29:01 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201A5F88F@RTITMBSV06.realtek.com.tw>
References: <1394712342-15778-272-Taiwan-albertk@realtek.com>
        <1394712342-15778-275-Taiwan-albertk@realtek.com>
 <20170613.130154.2119986704513730261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613.130154.2119986704513730261.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, June 14, 2017 1:02 AM
> > v2:
> > For #1, replace GFP_KERNEL with GFP_NOIO for usb_submit_urb().
> >
> > v1:
> > Improve the flow about runtime suspend/resume and make the code
> > easy to read.
> 
> Series applied.

Excuse me. I don't see these patches in net-next repository. Where could I find them?

Best Regards,
Hayes
