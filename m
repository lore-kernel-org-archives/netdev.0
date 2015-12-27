From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Small improvements for the at803x PHY driver
Date: Sat, 26 Dec 2015 19:29:50 -0800
Message-ID: <567F5B2E.9050705@gmail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
 <567E809D.3000902@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Mack <daniel@zonque.org>,
	Fabio Estevam <festevam@gmail.com>,
	Mans Rullgard <mans@mansr.com>
To: Mason <slash.tmp@free.fr>,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34832 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbbL0D3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2015 22:29:52 -0500
Received: by mail-ob0-f178.google.com with SMTP id 18so216167543obc.2
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2015 19:29:51 -0800 (PST)
In-Reply-To: <567E809D.3000902@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/12/2015 03:57, Mason a =C3=A9crit :
> [ CCing people who might be interested in this patch series ]
>=20
> On 26/12/2015 01:26, Martin Blumenstingl wrote:
>=20
>> while trying to debug a problem on a board with an AR8030 PHY (which=
 turned
>> out to be an incorrectly configured MDC clock) I made a few changes =
to the
>> at803x driver.
>> Due to lack of other hardware I could only test these changes with a=
n
>> AR8030 chip.
>=20

Overall, this looks pretty nice to me, few comments in individual patch=
es.
--=20
=46lorian
