From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 07:41:42 -0500
Message-ID: <630308a2-1933-11a8-9b95-116e3f5a9d61@pobox.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161125002702.GA14085@electric-eye.fr.zoreil.com>
 <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com>
 <4e370db9-f6b2-edd4-537b-d5a45b2ddea1@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
        David Miller <davem@davemloft.net>, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4e370db9-f6b2-edd4-537b-d5a45b2ddea1@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-25 07:34 AM, Mark Lord wrote:
> On 16-11-25 04:53 AM, Greg KH wrote:
>> Note, there are "cheap" USB monitors that can be quite handy and that work on Linux:
>> 	http://www.totalphase.com/products/beagle-usb12/
> 
> USD$455/each in quantity, vs. USD$8 for the USB ethernet dongle.

Oh, wrong model.  That one doesn't do USB2.
The USB2 version is a mere USD$1300 in quantity.

Seems like rather a lot of money just to report a bug in a USB driver.
Perhaps the Linux Foundation might purchase one and loan it for this task?
