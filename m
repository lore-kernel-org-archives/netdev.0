From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2015-06-18
Date: Tue, 23 Jun 2015 13:29:03 +0200
Message-ID: <F6D7F62D-3444-496B-BB43-0844129A4738@holtmann.org>
References: <20150618184311.GA30772@t440s.P-661HNU-F1> <20150623.032255.394457596589182499.davem@davemloft.net> <558939EE.10206@peakwork.de>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Markus Pfau <markus.pfau-9kPUpXxpYhgb1SvskN2V4Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <558939EE.10206-9kPUpXxpYhgb1SvskN2V4Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Markus,

>>> Here's the final bluetooth-next pull request for 4.2.
>>> 
>>>  - Cleanups & fixes to 802.15.4 code and related drivers
>>>  - Fix btusb driver memory leak
>>>  - New USB IDs for Atheros controllers
>>>  - Support for BCM4324B3 UART based Broadcom controller
>>>  - Fix for Bluetooth encryption key size handling
>>>  - Broadcom controller initialization fixes
>>>  - Support for Intel controller DDC parameters
>>>  - Support for multiple Bluetooth LE advertising instances
>>>  - Fix for HCI user channel cleanup path
>>> 
>>> Please let me know if there are any issues pulling. Thanks.
>> Pulled, thanks Johan,
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Hi David,
> 
> I didn't get any response to my issue "High CPU load when turning off BT keyboard" from 2015-06-15.
> Is it already fixed in "Fix for HCI user channel cleanup path" ?


your issue is an userspace daemon issue and not a kernel issue. This pull request is for the kernel side of the Bluetooth subsystem. None of these have anything to do with the userspace daemon.

I am sorry that your email has not yet been answered. However it is only 10 days old and I bet one of the maintainers for the userspace code will have a look at it soon. If not, then you can always resend it to get their attention.

Regards

Marcel
