From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Mellanox ethernet card failed when probing
Date: Fri, 3 Feb 2012 16:58:21 +0100
Message-ID: <CAL8zT=jOH44NxWm3SNdDtTvOgrAYi2RHH-wDk4u0-rU2KG88tA@mail.gmail.com>
References: <CAL8zT=gV=pe4Bnn188ngnPk8s=7JSGARY0g6uVHASVrUXNKeKg@mail.gmail.com>
 <1328282773.2157.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39437 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145Ab2BCP6m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:58:42 -0500
Received: by werb13 with SMTP id b13so2805390wer.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 07:58:41 -0800 (PST)
In-Reply-To: <1328282773.2157.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/2/3 Eric Dumazet <eric.dumazet@gmail.com>:
> Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 16:13 +0100, Jean-Michel Haut=
bois a
> =C3=A9crit :
>
>> I think this is firmware related, but I don't know for sure.
>> I can't find any firmware generated in the /lib/firmware directory..=
=2E
>
> Take a look here :
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/firmware/linux-firmware.g=
it;a=3Dsummary
>

I thought it could be a firmware problem, but when I activate
debug_level it tells me "FW version 2.8.000" so, it loads it...
I have a probe issue, -22 means invalid value, but I don't know why.
Maybe will I need to debug it, in order to find the line which fails
and why, but I wondered if some people in here could have answers to
it :).
My device is a 15b3:6764 (Mellanox MT2648).

JM
