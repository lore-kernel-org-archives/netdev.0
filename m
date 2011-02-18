From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in
 2.6.38-rc4
Date: Fri, 18 Feb 2011 20:13:49 +0100
Message-ID: <1298056429.2425.24.camel@edumazet-laptop>
References: <20110217090910.GA3781@tiehlicka.suse.cz>
	 <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
	 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
	 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
	 <20110218122938.GB26779@tiehlicka.suse.cz>
	 <20110218162623.GD4862@tiehlicka.suse.cz>
	 <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
	 <m17hcx43m3.fsf@fess.ebiederm.org>
	 <AANLkTikh4oaR6CBK3NBazer7yjhE0VndsUB5FCDRsbJc@mail.gmail.com>
	 <20110218190128.GF13211@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:41383 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab1BRTOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 14:14:22 -0500
In-Reply-To: <20110218190128.GF13211@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 17:01 -0200, Arnaldo Carvalho d=
e Melo a
=C3=A9crit :

> Original code is ANK's, I just made it possible to use with DCCP, and
> yeah, the smiley is appropriate, something 6 years old and the world
> around it changing continually... well, thanks for the git blame ;-)
>=20

At that time, net namespaces did not exist.

I would blame people implementing them ;)



