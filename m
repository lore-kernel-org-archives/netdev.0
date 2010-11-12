From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 17:33:45 +0800
Message-ID: <20101112093345.GC5949@cr0.nay.redhat.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
 <1289489007.17691.1310.camel@edumazet-laptop>
 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
 <20101112071323.GB5660@cr0.nay.redhat.com>
 <1289546874.17691.1774.camel@edumazet-laptop>
 <20101112081945.GA5949@cr0.nay.redhat.com>
 <1289553759.3185.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46136 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab0KLJ3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 04:29:01 -0500
Content-Disposition: inline
In-Reply-To: <1289553759.3185.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 12, 2010 at 10:22:39AM +0100, Eric Dumazet wrote:
>Le vendredi 12 novembre 2010 =C3=A0 16:19 +0800, Am=C3=A9rico Wang a =C3=
=A9crit :
>> On Fri, Nov 12, 2010 at 08:27:54AM +0100, Eric Dumazet wrote:
>
>> >A RCU conversion is far more complex.
>> >
>>=20
>> Yup.
>
>
>Well, actually this is easy in this case.
>
>I'll post a patch to do this RCU conversion.
>

Cool! Please keep me in Cc.

Some conversions from rwlock to RCU are indeed complex,
don't know about this case.

Anyway, patch please. :)
