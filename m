From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB 10/100 RJ45 Ethernet Network Adapter
Date: Tue, 22 Feb 2011 11:24:03 -0800 (PST)
Message-ID: <20110222.112403.179931392.davem@davemloft.net>
References: <20110222140705.GA6055@redhat.com>
	<4D640C0F.3050703@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shaharh@redhat.com, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, jacmet@sunsite.dk, gregkh@suse.de,
	netdev@vger.kernel.org
To: sshtylyov@mvista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D640C0F.3050703@ru.mvista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sshtylyov@mvista.com>
Date: Tue, 22 Feb 2011 22:18:39 +0300

> Hello.
> 
> Shahar Havivi wrote:
> 
>> The device is very similar to (0x0fe6, 0x8101),
>> And works well with dm9601 driver.
> 
>   You should sign off your patch in order for it to be merged.

He did, see the follow-up patch with subject

[PATCH-v2] Added support for usb ethernet (0x0fe6, 0x9700)
