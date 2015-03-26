From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link status signaling
Date: Thu, 26 Mar 2015 20:23:34 +0300
Message-ID: <55144096.6060800@list.ru>
References: <55142C31.5050504@list.ru> <55143E3F.9080501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp47.i.mail.ru ([94.100.177.107]:38550 "EHLO smtp47.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbbCZRXp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 13:23:45 -0400
In-Reply-To: <55143E3F.9080501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

26.03.2015 20:13, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hello,
>
> On 26/03/15 08:56, Stas Sergeev wrote:
>> Hello.
>>
>> The following patches are needed when mvneta is used
>> in SGMII mode without MDIO.
> Would you mind using scripts/get_maintainer.pl such that the relevant
> people who have touched this code in the past can be CC'd?
>
> Your patches are barely readable, let alone that you have provided
> little to explanation as to why you are making such invasive changes.
OK, will re-send tomorrow with more explanations and CCs.
Still not sure about "barely readable" though - I made them
through checkpatch.pl.
