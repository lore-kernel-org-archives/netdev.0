From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: add helper checking for BCM4707 / BCM53018 chip id
Date: Sat, 30 Jan 2016 10:49:50 +0100
Message-ID: <CACna6ry1FwQuqQ-jzB0DQN+uXpH7XZid5bc-pOp=JkJbt2JOMw@mail.gmail.com>
References: <1454110867-9489-1-git-send-email-zajec5@gmail.com>
	<20160129.230326.2013535528827383323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35798 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001AbcA3Jtv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 04:49:51 -0500
Received: by mail-io0-f181.google.com with SMTP id d63so95891930ioj.2
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2016 01:49:51 -0800 (PST)
In-Reply-To: <20160129.230326.2013535528827383323.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 January 2016 at 08:03, David Miller <davem@davemloft.net> wrote:
> From: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Date: Sat, 30 Jan 2016 00:41:07 +0100
>
>> Chipsets with BCM4707 / BCM53018 ID require special handling at a fe=
w
>> places in the code. It's likely there will be more IDs to check in t=
he
>> future. To simplify it add this trivial helper.
>>
>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>
> The net-next tree is not open, therefore submitting this kind of clea=
nup
> is not appropriate.

Oops, I got experience from other trees where patches are just queued
(usually with patchwork). I just read about netdev not playing this
way in netdev-FAQ.txt, I didn't expect that. I'll resubmit it later.

--=20
Rafa=C5=82
