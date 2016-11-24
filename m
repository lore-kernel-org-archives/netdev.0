From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 11:21:52 -0500 (EST)
Message-ID: <20161124.112152.692025478489876693.davem@davemloft.net>
References: <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
        <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
        <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlord@pobox.com, netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 24 Nov 2016 13:26:55 +0000

> I don't think the garbage results from our driver or device.

This is my impression with what has been presented so far as well.
