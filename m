From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] r8152: adjust runtime suspend/resume
Date: Fri, 16 Jun 2017 11:37:47 -0400 (EDT)
Message-ID: <20170616.113747.116879754972428796.davem@davemloft.net>
References: <1394712342-15778-275-Taiwan-albertk@realtek.com>
        <20170613.130154.2119986704513730261.davem@davemloft.net>
        <0835B3720019904CB8F7AA43166CEEB201A5F88F@RTITMBSV06.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201A5F88F@RTITMBSV06.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 16 Jun 2017 03:29:01 +0000

> David Miller [mailto:davem@davemloft.net]
>> Sent: Wednesday, June 14, 2017 1:02 AM
>> > v2:
>> > For #1, replace GFP_KERNEL with GFP_NOIO for usb_submit_urb().
>> >
>> > v1:
>> > Improve the flow about runtime suspend/resume and make the code
>> > easy to read.
>> 
>> Series applied.
> 
> Excuse me. I don't see these patches in net-next repository. Where could I find them?

Sorry, I don't know how that happened.

It should be there now.

Thanks.
