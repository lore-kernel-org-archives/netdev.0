From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Fri, 16 Dec 2011 20:44:49 +0100
Message-ID: <1324064689.2621.24.camel@edumazet-laptop>
References: <4EE8F884.1010304@hp.com>
	 <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
	 <1323970998.2769.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA3D58.5010101@hp.com>
	 <20111215104440.1eef9e47@s6510.linuxnetplumber.net>
	 <1323975606.2769.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EEA730E.5010405@hp.com> <1324009676.2562.9.camel@edumazet-laptop>
	 <4EEB9D64.5080901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Matthew Vick <matthew.vick@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47297 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952Ab1LPTox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 14:44:53 -0500
Received: by werm1 with SMTP id m1so574730wer.19
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 11:44:52 -0800 (PST)
In-Reply-To: <4EEB9D64.5080901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 11:35 -0800, Rick Jones a =C3=A9=
crit :

> I would *love* to.  All my accessible igb-driven hardware is in an=20
> environment locked to the kernels already there :(  Not that it makes=
 it=20
> more possible for me to do it, but I suspect it does not require 30=20
> receivers to reproduce the dups with netperf TCP_STREAM.  Particularl=
y=20
> if the tx queue len is at 256 it may only take 6 or 8. In fact let me=
=20
> try that now...
>=20
> Yep, with just 8 destinations/concurrent TCP_STREAM tests from the on=
e=20
> system one can still see the duplicates in the packet trace taken on =
the=20
> sender.
>=20
> Perhaps we can trouble the Intel guys to try to reproduce what I've s=
een?
>=20

I do have an igb card somewhere (in fact two dual ports), I'll do the
test myself !

Thanks
