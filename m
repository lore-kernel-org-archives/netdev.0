From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Regulator support for smsc911x
Date: Tue, 7 Feb 2012 18:29:17 -0200
Message-ID: <CAOMZO5C=w6DDue1n-JbN7UHfnFDpLO9RN113QpFwtfQgjdSafg@mail.gmail.com>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
	<CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
	<20120203074408.GD1990@pengutronix.de>
	<20120203111133.GD3151@opensource.wolfsonmicro.com>
	<CAOMZO5B2_yq=m8Mer=iV-HsXvF-MZJ-BV2=LTg1CZN+O=yepSQ@mail.gmail.com>
	<20120207193914.GA31557@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	robert.marklund@stericsson.com, netdev@vger.kernel.org,
	Sascha Hauer <kernel@pengutronix.de>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:65368 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab2BGU3S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:29:18 -0500
Received: by eaah12 with SMTP id h12so2955934eaa.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 12:29:17 -0800 (PST)
In-Reply-To: <20120207193914.GA31557@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2012 at 5:39 PM, Mark Brown
<broonie@opensource.wolfsonmicro.com> wrote:

> Really, anyone who wants this sort of thing should just enable dummy
> regulators - it's exactly what you're implementing. =C2=A0I'm pretty =
sure
> your board does actually have power supplies for the chip, you've jus=
t
> not told software about them.

Ok, I have sent a patch adding the regulators.

Thanks,

=46abio Estevam
