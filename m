From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: repository for switch hardware info
Date: Tue, 10 Mar 2015 19:02:58 +0530
Message-ID: <CA+CtxLQ=ByYDugho5XeOKEn2v2c67qtDd0Q=Cb=ocKn=_r4mdA@mail.gmail.com>
References: <CANmuVZcYEyoqDhtY+5UWakYqYa6MqO4hj2MNwE1uWH=hcUKcrA@mail.gmail.com>
	<00a201d0551b$d982f2a0$8c88d7e0$@codeaurora.org>
	<20150302.154006.225049966274593660.davem@davemloft.net>
	<20150302.155735.937483543338955659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:43863 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbbCJNdA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 09:33:00 -0400
Received: by widem10 with SMTP id em10so3015795wid.2
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 06:32:58 -0700 (PDT)
In-Reply-To: <20150302.155735.937483543338955659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Broadcom's Open Network Switch Library is available at the below location.

https://github.com/Broadcom-Switch/OpenNSL

On Tue, Mar 3, 2015 at 2:27 AM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 02 Mar 2015 15:40:06 -0500 (EST)
>
>> From: "Mathieu Olivari" <mathieu@codeaurora.org>
>> Date: Mon, 2 Mar 2015 11:05:28 -0800
>>
>>> Here is what's available publically for QCA devices.
>>>
>>> AR8xxx/QCA8xxx (Ethernet xMII/MDIO based hardware switch widely deployed in home gateways):
>>> - open source vendor SDK is available here: https://www.codeaurora.org/cgit/quic/qsdk/oss/lklm/qca-ssdk/ (configuration command can be found in https://www.codeaurora.org/cgit/quic/qsdk/oss/ssdk-shell/)
>>> - same devices (AR8xxx/QCA8xxx) are also supported by OpenWrt using a swconfig based driver: http://git.openwrt.org/?p=openwrt.git;a=tree;f=target/linux/generic/files/drivers/net/phy;h=ceb9d8c46e7ffb936e3e56dcf77a0253fa5b3468;hb=HEAD (files ar8216.c & ar8327.c)
>>>
>>> IPQ806x (NPU we talked about during netdev01):
>>> - code is available here: https://www.codeaurora.org/cgit/quic/qsdk/
>>> Driver is split between oss/lklm/nss-drv, oss/lklm/nss-gmac and oss/lklm/qca-nss-ecm.
>>>
>>> Both hardware can easily be found in home routers on the market today.
>>
>> Please post this publicly on the mailing list rather than as a private
>> email to just me.
>
> Sorry I'm an idiot, I didn't see netdev in the CC: :-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Regards,
Siva Mannem.
