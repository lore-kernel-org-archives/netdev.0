From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Fri, 10 Feb 2012 14:25:45 +0100
Message-ID: <1328880345.2443.17.camel@edumazet-laptop>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
	 <4F349DB0.1010903@gmail.com> <4F34AE62.6070409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, Jeff Kirsher <tarbal@gmail.com>,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59747 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757952Ab2BJNZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 08:25:50 -0500
Received: by wics10 with SMTP id s10so2008851wic.19
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 05:25:49 -0800 (PST)
In-Reply-To: <4F34AE62.6070409@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 f=C3=A9vrier 2012 =C3=A0 21:42 -0800, Ben Greear a =C3=A9cr=
it :
> On 02/09/2012 08:31 PM, Jeff Kirsher wrote:
>=20
> > Thanks Ben!
> >
> > I have applied the series of 10 patches to my queue.  I would like =
to
> > have our validation team validate the e100, e1000 and e1000e patche=
s
> > (and in-directly the net patches).
>=20
> Just in case you can generate errored frames other than ones with jus=
t
> bad FCS, I'm curious to know if rx-all logic works with them.
>=20
> I was thinking I might could get at least some NICs to generate Runt =
frames
> by sending small pkts and disabling frame padding, but haven't looked=
 into
> it too hard yet.

I am interested by this, do you know some NICs able to disable frame
padding ?
