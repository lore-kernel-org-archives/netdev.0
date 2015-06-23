From: Markus Pfau <markus.pfau-9kPUpXxpYhgb1SvskN2V4Q@public.gmane.org>
Subject: Re: pull request: bluetooth-next 2015-06-18
Date: Tue, 23 Jun 2015 12:50:22 +0200
Message-ID: <558939EE.10206@peakwork.de>
References: <20150618184311.GA30772@t440s.P-661HNU-F1>
 <20150623.032255.394457596589182499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150623.032255.394457596589182499.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 23.06.2015 um 12:22 schrieb David Miller:
> From: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 18 Jun 2015 21:43:11 +0300
>
>> Here's the final bluetooth-next pull request for 4.2.
>>
>>   - Cleanups & fixes to 802.15.4 code and related drivers
>>   - Fix btusb driver memory leak
>>   - New USB IDs for Atheros controllers
>>   - Support for BCM4324B3 UART based Broadcom controller
>>   - Fix for Bluetooth encryption key size handling
>>   - Broadcom controller initialization fixes
>>   - Support for Intel controller DDC parameters
>>   - Support for multiple Bluetooth LE advertising instances
>>   - Fix for HCI user channel cleanup path
>>
>> Please let me know if there are any issues pulling. Thanks.
> Pulled, thanks Johan,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Hi David,

I didn't get any response to my issue "High CPU load when turning off BT 
keyboard" from 2015-06-15.
Is it already fixed in "Fix for HCI user channel cleanup path" ?

Its really an annoying issue because the CPU on my embedded board never 
turns into idle and the fan is running.
I'm able to restart BlueTooth, but not my wife :-)

Thank you!

Markus
