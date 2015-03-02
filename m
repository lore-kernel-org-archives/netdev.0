From: David Miller <davem@davemloft.net>
Subject: Re: repository for switch hardware info
Date: Mon, 02 Mar 2015 15:57:35 -0500 (EST)
Message-ID: <20150302.155735.937483543338955659.davem@davemloft.net>
References: <CANmuVZcYEyoqDhtY+5UWakYqYa6MqO4hj2MNwE1uWH=hcUKcrA@mail.gmail.com>
	<00a201d0551b$d982f2a0$8c88d7e0$@codeaurora.org>
	<20150302.154006.225049966274593660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mathieu@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbbCBU5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 15:57:37 -0500
In-Reply-To: <20150302.154006.225049966274593660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 02 Mar 2015 15:40:06 -0500 (EST)

> From: "Mathieu Olivari" <mathieu@codeaurora.org>
> Date: Mon, 2 Mar 2015 11:05:28 -0800
> 
>> Here is what's available publically for QCA devices.
>> 
>> AR8xxx/QCA8xxx (Ethernet xMII/MDIO based hardware switch widely deployed in home gateways):
>> - open source vendor SDK is available here: https://www.codeaurora.org/cgit/quic/qsdk/oss/lklm/qca-ssdk/ (configuration command can be found in https://www.codeaurora.org/cgit/quic/qsdk/oss/ssdk-shell/) 
>> - same devices (AR8xxx/QCA8xxx) are also supported by OpenWrt using a swconfig based driver: http://git.openwrt.org/?p=openwrt.git;a=tree;f=target/linux/generic/files/drivers/net/phy;h=ceb9d8c46e7ffb936e3e56dcf77a0253fa5b3468;hb=HEAD (files ar8216.c & ar8327.c)
>> 
>> IPQ806x (NPU we talked about during netdev01):
>> - code is available here: https://www.codeaurora.org/cgit/quic/qsdk/
>> Driver is split between oss/lklm/nss-drv, oss/lklm/nss-gmac and oss/lklm/qca-nss-ecm.
>> 
>> Both hardware can easily be found in home routers on the market today.
> 
> Please post this publicly on the mailing list rather than as a private
> email to just me.

Sorry I'm an idiot, I didn't see netdev in the CC: :-)
