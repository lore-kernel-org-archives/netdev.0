From: Ralf Friedl <Ralf.Friedl@online.de>
Subject: Re: Problem with Reaktek 8168
Date: Thu, 21 Feb 2013 01:48:07 +0100
Message-ID: <51256EC7.90505@online.de>
References: <5124B909.4080907@online.de> <20130220231122.GA22163@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:60991 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3BUAsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 19:48:04 -0500
In-Reply-To: <20130220231122.GA22163@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Ralf Friedl <Ralf.Friedl@online.de> :
> [...]
>   
>> If it helps I can also run a custom driver with additional debug code.
>>     
> Can you send the XID line that your stock kernel r8169 driver displays ?
> It will help identifying your chipset revision as a start.
>   
Thank you for your reply.
These are the messages when the driver loads.

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:00.0: irq 90 for MSI/MSI-X
r8169 0000:02:00.0: eth0: RTL8168f/8111f at 0xffffc90010122000, 
50:46:5d:a7:30:7a, XID 08000880 IRQ 90
r8169 0000:02:00.0: eth0: jumbo features [frames: 9200 bytes, tx 
checksumming: ko]

Ralf Friedl
