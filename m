From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: under-performing bonded interfaces
Date: Thu, 22 Dec 2011 06:43:13 +0100
Message-ID: <1324532593.2621.26.camel@edumazet-laptop>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	 <4EC44ECB.4050201@candelatech.com>
	 <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
	 <1321491449.2709.90.camel@bwh-desktop>
	 <CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
	 <1321498314.2885.78.camel@deadeye>
	 <CANj2Eben0hrP6KwxyA1WPqiqzm84w=J2_sdtrKtGvxdftuksqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38144 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab1LVFnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 00:43:17 -0500
Received: by wgbdr13 with SMTP id dr13so15335431wgb.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 21:43:16 -0800 (PST)
In-Reply-To: <CANj2Eben0hrP6KwxyA1WPqiqzm84w=J2_sdtrKtGvxdftuksqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 20:26 -0500, Simon Chen a =C3=A9=
crit :
> Hi folks,
>=20
> I added an Intel X520 card to both the sender and receiver... Now I
> have two 10G ports on a PCIe 2.0 x8 slot (5Gx8), so the bandwidth of
> the PCI bus shouldn't be the bottleneck.
>=20
> Now the throughput test gives me around 16Gbps in aggregate. Any idea=
s
> how I can push closer to 20G? I don't quite understand where the
> bottleneck is now.

Could you post some "perf top" or "perf record / report" numbers ?
