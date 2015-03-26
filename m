From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link status signaling
Date: Thu, 26 Mar 2015 20:34:33 +0300
Message-ID: <55144329.3040501@list.ru>
References: <55142C31.5050504@list.ru> <55143E3F.9080501@gmail.com> <55144096.6060800@list.ru> <551441FA.1010504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp22.mail.ru ([94.100.181.177]:58830 "EHLO smtp22.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbbCZReh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 13:34:37 -0400
In-Reply-To: <551441FA.1010504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

26.03.2015 20:29, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 26/03/15 10:23, Stas Sergeev wrote:
>> 26.03.2015 20:13, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Hello,
>>>
>>> On 26/03/15 08:56, Stas Sergeev wrote:
>>>> Hello.
>>>>
>>>> The following patches are needed when mvneta is used
>>>> in SGMII mode without MDIO.
>>> Would you mind using scripts/get_maintainer.pl such that the releva=
nt
>>> people who have touched this code in the past can be CC'd?
>>>
>>> Your patches are barely readable, let alone that you have provided
>>> little to explanation as to why you are making such invasive change=
s.
>> OK, will re-send tomorrow with more explanations and CCs.
>> Still not sure about "barely readable" though - I made them
>> through checkpatch.pl.
> Your commit messages are very scarce, you need to explain more what y=
ou
> are doing an why.
That's OK, will do, thanks.
You said that my patches and barely readable AND have
little explanation, so I thought you mean the code changes
itself are barely readable too.
