From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6 2/2] e1000e: use GFP_KERNEL allocations at
 init time
Date: Mon, 11 Jul 2011 19:58:46 -0700
Message-ID: <CAL3LdT7MjdcqoCKMGnqBuuBNy86ZDhfLsQMnaqcc=8toP_GuCQ@mail.gmail.com>
References: <CAL3LdT7WNrkDk2WrTnDnwYJ2raoNJdG5v4q=gk4o8hc2KR1Q_w@mail.gmail.com>
	<20110711.193359.1440272794251078589.davem@davemloft.net>
	<1310438432.2438.26.camel@jtkirshe-mobl>
	<20110711.194556.1386145743297508794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com, bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:53900 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214Ab1GLC6r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 22:58:47 -0400
Received: by fxd18 with SMTP id 18so4538346fxd.11
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 19:58:46 -0700 (PDT)
In-Reply-To: <20110711.194556.1386145743297508794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 19:45, David Miller <davem@davemloft.net> wrote=
:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 11 Jul 2011 19:40:31 -0700
>
>> On Mon, 2011-07-11 at 19:33 -0700, David Miller wrote:
>>> You can't until I put patch #1 into my tree, which adds the
>>> new interfaces used by this patch.
>>
>> I applied patch #1 to my queue as well (for testing purposes) since =
I
>> saw that patch #2 was dependent. =C2=A0If it passes testing, I (or B=
ruce)
>> will just ACK patch #2, that way you can apply both patches at the s=
ame
>> time.
>
> Ok.
> --

Hmm, this patch has 4 checkpatch.pl warnings so I guess I will be
sending you an updated version of the patch (if patch #1 is fine and
gets accepted) after we finish testing.

--=20
Cheers,
Jeff
