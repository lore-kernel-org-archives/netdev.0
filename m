From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] natsemi: silence dma-debug warnings
Date: Sun, 10 Jul 2011 07:07:18 -0700 (PDT)
Message-ID: <20110710.070718.80546495283792713.davem@davemloft.net>
References: <20110703.223448.458910310802724750.davem@davemloft.net>
	<CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
	<20110710.102039.1305564732068163396.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jim.cromie@gmail.com, thockin@hockin.org, netdev@vger.kernel.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab1GJOHi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 10:07:38 -0400
In-Reply-To: <20110710.102039.1305564732068163396.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Sun, 10 Jul 2011 10:20:39 +0900 (JST)

> On Sat, 9 Jul 2011 14:11:25 -0600
> Jim Cromie <jim.cromie@gmail.com> wrote:
>=20
>> On Sun, Jul 3, 2011 at 11:34 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>> Date: Mon, 4 Jul 2011 14:30:19 +0900
>>>
>>>> This silences dma-debug warnings:
>>>>
>>>> https://lkml.org/lkml/2011/6/30/341
>>> =A0...
>>>> Reported-by: Jim Cromie <jim.cromie@gmail.com>
>>>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>>> Tested-by: Jim Cromie <jim.cromie@gmail.com>
>>>
>>> Applied, thanks!
>>>
>>=20
>> I have since seen a similar warning on shutdown,
>> heres a patch for it.
>=20
> Oops, I noticed this too but I forgot to send a patch.
>=20
> The patch looks good to me.

I'll apply this, thanks.
