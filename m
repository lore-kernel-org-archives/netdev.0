From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: libpcap and tc filters
Date: Tue, 05 Jul 2011 18:14:45 +0200
Message-ID: <1309882485.2271.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	 <1309777908.26180.1.camel@mojatatu>
	 <CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	 <CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	 <1309784740.26180.21.camel@mojatatu>
	 <CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
	 <1309788416.26180.63.camel@mojatatu>
	 <CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
	 <1309863403.1765.0.camel@mojatatu> <1309870021.1765.41.camel@mojatatu>
	 <CAA0qwj5aBWrsqHGddW9FBV2srdGwVMzJKe84BTyRH0Dkr6KgVQ@mail.gmail.com>
	 <1309874213.1765.45.camel@mojatatu>
	 <CAA0qwj74cvZmkkmA8zBFuXeHdidMco2=de7Li9rDN5Wcp=-G7w@mail.gmail.com>
	 <1309876868.1765.53.camel@mojatatu>
	 <CAA0qwj49XzNa-nY82X3d_eZ95seS15qELbJDYCNfRkg03OJosQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: Adam Katz <adamkatz0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58165 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703Ab1GEQO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:14:59 -0400
Received: by wyg8 with SMTP id 8so4107241wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 09:14:58 -0700 (PDT)
In-Reply-To: <CAA0qwj49XzNa-nY82X3d_eZ95seS15qELbJDYCNfRkg03OJosQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 18:16 +0300, Adam Katz a =C3=A9crit :
> strange.
> I've now tried the exact same configuration and it simply refuses to
> work. Maybe your tcpreplay is configured differently...
>=20
> What distro are you using? What kernel? What version of libpcap?

I did the same tests here and it works correctly for me.

latest kernel 3.0-rc6

# /usr/local/bin/tcpreplay -V
tcpreplay version: 3.4.4 (build 2450)
Copyright 2000-2010 by Aaron Turner <aturner at synfin dot net>
Cache file supported: 04
Not compiled with libdnet.
Compiled against libpcap: 1.1.1
64 bit packet counters: enabled
Verbose printing via tcpdump: enabled
Packet editing: disabled
=46ragroute engine: disabled
Injection method: PF_PACKET send()


