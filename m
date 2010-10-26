From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: push settings
 to platform resources
Date: Mon, 25 Oct 2010 21:54:48 -0400
Message-ID: <AANLkTi=jfho4yd_gSMfKywBPkD_=smgnP_yLtRh=00jv@mail.gmail.com>
References: <1287727161-24671-1-git-send-email-vapier@gentoo.org>
 <20101024.161722.258113499.davem@davemloft.net> <AANLkTik5_a6t5xJ9TWJf37UCL52O02nAQY4YwB6mgnQx@mail.gmail.com>
 <20101024.164534.241451843.davem@davemloft.net> <AANLkTik6C2tbir0hKJJ2kErha-JJD_yx927qw=3t7=Xu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35044 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755729Ab0JZBzJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 21:55:09 -0400
Received: by wwe15 with SMTP id 15so4203426wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 18:55:08 -0700 (PDT)
In-Reply-To: <AANLkTik6C2tbir0hKJJ2kErha-JJD_yx927qw=3t7=Xu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 19:51, Mike Frysinger wrote:
> On Sun, Oct 24, 2010 at 19:45, David Miller wrote:
>> From: Mike Frysinger
>>> and i have the Blackfin changes waiting for you to merge this patch=
=2E
>>> i can squash them into this change and have you merge the result, o=
r i
>>> can merge it. =C2=A0i dont really care either way.
>>
>> Why don't you just apply this to your tree then. =C2=A0Feel free to =
add my:
>
> thanks, i'll do that

Linus has taken this via my tree now.  are you going to merge the
other patches ?  or do i need to resend them ?
-mike
