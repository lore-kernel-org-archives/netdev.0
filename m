From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH 2/2 v2] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Tue, 29 Mar 2011 13:26:27 +0200
Message-ID: <AANLkTikcQyvAhVrjhJKdVexU2EaGtjMqHoK7BfKSq9Jg@mail.gmail.com>
References: <1301315152.3182.19.camel@edumazet-laptop> <AANLkTi=Qkf2qn6nQ-6AXE8LtFSD++=eZRxa6ND6KPsk1@mail.gmail.com>
 <1301332822.2716.12.camel@bwh-desktop> <20110328.165311.226778266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	error27@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48307 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782Ab1C2L1G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 07:27:06 -0400
In-Reply-To: <20110328.165311.226778266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 1:53 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 28 Mar 2011 18:20:22 +0100
>
>> On Mon, 2011-03-28 at 17:46 +0200, Javier Martinez Canillas wrote:
>>> Yes this definitely is not janitor material :)
>>>
>>> I just sent the patch because I saw IRQF_SAMPLE_RANDOM in
>>> Documentation/feature-removal-schedule.txt. I can resend a patch
>>> removing the macro in the remaining network cards if the decision i=
s
>>> to remove IRQF_SAMPLE_RANDOM.
>>
>> It's not my call, but I would support it.
>
> FWIW, I support it too.
>

Ok, I just sent a patch removing the IRQF_SAMPLE_RANDOM flag in all
the network drivers in the case everyone agrees.

Best regards,

-----------------------------------------
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
PhD Student in High Performance Computing
Computer Architecture and Operating System Department (CAOS)
Universitat Aut=C3=B2noma de Barcelona
Barcelona, Spain
