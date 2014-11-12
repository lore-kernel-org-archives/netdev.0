From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Wed, 12 Nov 2014 00:43:31 -0500 (EST)
Message-ID: <20141112.004331.1112374574697663525.davem@davemloft.net>
References: <0835B3720019904CB8F7AA43166CEEB2ECE429@RTITMBSV03.realtek.com.tw>
	<20141112.001318.1905417679166281362.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2ECE442@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2ECE442@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 12 Nov 2014 05:23:03 +0000

> David Miller [mailto:davem@davemloft.net] 
>> Sent: Wednesday, November 12, 2014 1:13 PM
> [...]
>> I really want to know why you are spending so much effort on this.
>> 
>> Is there a real situation that happened very often, which you
>> diagnosed in detail, and therefore you want to address?
> 
> No. I just consider the possible situation and want to
> make the driver better. If you think this is unnecessary,
> I would remove it.

What do other USB network drivers do in similar situations?
