From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 10 Mar 2015 22:27:18 +0100
Message-ID: <54FF61B6.3050307@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <9234001.YBqfvtcJFx@fuchs> <5496E135.1@broadcom.com> <9062978.Vq0rTjKd5z@fuchs> <20150309205451.GA13884@minime.bse>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Michael Tokarev <mjt@tls.msk.ru>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	"brcm80211 development" <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Network Development" <netdev@vger.kernel.org>,
	Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64748 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbbCJV10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 17:27:26 -0400
In-Reply-To: <20150309205451.GA13884@minime.bse>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/15 21:54, Daniel Gl=C3=B6ckner wrote:
> Hi Arend,
>
> On Sun, Dec 21, 2014 at 06:34:24PM +0100, Maximilian Engelhardt wrote=
:
>> On Sunday 21 December 2014 16:03:17 Arend van Spriel wrote:
>>> On 12/21/14 15:24, Maximilian Engelhardt wrote:
>>>> On Sunday 21 December 2014 15:13:50 Arend van Spriel wrote:
>>>>> Thanks. It shows you have have the same bt-coex version as Michae=
l. I am
>>>>> not familiar with bluetooth side of things. Are you both using bl=
uetooth
>>>>> on 4313?
>>>>>
>>>>> Regards,
>>>>> Arend
>>>>
>>>> I don't know. I think I have Bluetooth somehow enabled but I'm not=
 really
>>>> using it. I definitely don't have any Bluetooth devices connected.=
 I could
>>>> try to unload/disable Bluetooth it to see if it makes any differen=
ce.
>>>
>>> That would be useful to know.
>>>
>>
>> I did a test with all Bluetooth modules unloaded that I could find b=
ut
>> throughput was still very low (about 4 Mbit/s with brcmsmac, my athe=
ros USB
>> stick archived about 110 Mbit/s).
>
> any update on this issue?
> One of my relatives would like to get rid of that Ralink wifi stick s=
he
> has been carrying around for 1.5 years now since the internal wifi in=
 her
> Thinkpad E130 suffers from this problem.

I did get my hands on same device as Michael has/had and it now sits in=
=20
my developement laptop. Just need to find some time to give it a spin.

Regards,
Arend

> Best regards,
>
>    Daniel
