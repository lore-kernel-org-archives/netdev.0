From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 10:22:39 +0100
Message-ID: <1289553759.3185.1.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	 <1289489007.17691.1310.camel@edumazet-laptop>
	 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	 <20101112071323.GB5660@cr0.nay.redhat.com>
	 <1289546874.17691.1774.camel@edumazet-laptop>
	 <20101112081945.GA5949@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101112081945.GA5949@cr0.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 12 novembre 2010 =C3=A0 16:19 +0800, Am=C3=A9rico Wang a =C3=
=A9crit :
> On Fri, Nov 12, 2010 at 08:27:54AM +0100, Eric Dumazet wrote:

> >A RCU conversion is far more complex.
> >
>=20
> Yup.


Well, actually this is easy in this case.

I'll post a patch to do this RCU conversion.
