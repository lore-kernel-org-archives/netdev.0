From: Grant Grundler <grundler@google.com>
Subject: Re: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Wed, 26 Feb 2014 09:09:27 -0800
Message-ID: <CANEJEGuuJ=Jt2gAY_LCURk4hg1XvPL_Er0G0mTHSY-YVt0On4g@mail.gmail.com>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
	<B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
	<CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com>
	<6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw>
	<CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com>
	<FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw>
	<CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com>
	<65183A93811745C58958ECBAD0B8E00F@realtek.com.tw>
	<CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com>
	<CANEJEGsMafeZQDfnmdgmf2VN0CKrTkjVHwKTX9JHTDUUqwx0Mg@mail.gmail.com>
	<FB59F84B1E5E42AA98F0906286C444DF@realtek.com.tw>
	<CANEJEGvMPMT3OroMGLJaR65uEz0+JVYkd5rxcPMMGT_wzvds+w@mail.gmail.com>
	<D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw>
	<CANEJEGuCWZSBNppE+W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com>
	<6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inki Yoo <inky.yoo@samsung.com>, netdev <netdev@vger.kernel.org>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:50756 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbaBZRJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 12:09:28 -0500
Received: by mail-ob0-f172.google.com with SMTP id wm4so1074007obc.31
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 09:09:27 -0800 (PST)
In-Reply-To: <6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 2:13 AM, hayeswang <hayeswang@realtek.com> wrote:
> Grant Grundler [mailto:grundler@google.com]
>> Sent: Tuesday, February 25, 2014 12:18 AM
>> To: hayeswang
>> Cc: Inki Yoo; netdev
>> Subject: Re: RTL8153 fails to get link after applying
>> c7de7dec2 to 3.8 kernel
> [...]
>> Does Realtek have a publicly available tool that I can use to set all
>> customization back to "official" values?
>
> Please contact with the person who give you the dangle.
> You should need the another one.

I'm having that conversation now since I don't know what firmware this
device has or how to update it.

> [...]
>> Sorry, I disagree. Where "customization" is available, I expect the
>> device driver to know/understand those values OR set them to some
>> state the driver knows how to deal with. This is a limitation of the
>> driver, not the HW.
>
> You couldn't fix it in ECM mode.
> The only way is to switch the config to the vendor mode.

Hrm. Or replace the firmware on the device?

cheers,
grant

>
> Best Regards,
> Hayes
>
