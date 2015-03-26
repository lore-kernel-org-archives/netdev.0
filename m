From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link status signaling
Date: Thu, 26 Mar 2015 10:29:30 -0700
Message-ID: <551441FA.1010504@gmail.com>
References: <55142C31.5050504@list.ru> <55143E3F.9080501@gmail.com> <55144096.6060800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33454 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbCZRaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 13:30:18 -0400
Received: by pdnc3 with SMTP id c3so69253277pdn.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:30:18 -0700 (PDT)
In-Reply-To: <55144096.6060800@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/03/15 10:23, Stas Sergeev wrote:
> 26.03.2015 20:13, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Hello,
>>
>> On 26/03/15 08:56, Stas Sergeev wrote:
>>> Hello.
>>>
>>> The following patches are needed when mvneta is used
>>> in SGMII mode without MDIO.
>> Would you mind using scripts/get_maintainer.pl such that the relevan=
t
>> people who have touched this code in the past can be CC'd?
>>
>> Your patches are barely readable, let alone that you have provided
>> little to explanation as to why you are making such invasive changes=
=2E
> OK, will re-send tomorrow with more explanations and CCs.
> Still not sure about "barely readable" though - I made them
> through checkpatch.pl.

Your commit messages are very scarce, you need to explain more what you
are doing an why.
--=20
=46lorian
