From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: netconsole as normal console for userspace messages?
Date: Tue, 1 Sep 2009 18:00:40 +0200
Message-ID: <200909011800.40243.a.miskiewicz@gmail.com>
References: <20090901101612.GB5222@ff.dom.local> <1251818111.3960.425.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:48140 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbZIAQAm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:00:42 -0400
Received: by fxm17 with SMTP id 17so133068fxm.37
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 09:00:44 -0700 (PDT)
In-Reply-To: <1251818111.3960.425.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 of September 2009, Matt Mackall wrote:
> On Tue, 2009-09-01 at 10:16 +0000, Jarek Poplawski wrote:
> > On 30-08-2009 02:12, Arkadiusz Miskiewicz wrote:
> > > Hi,
> >
> > Hi,
> >
> > > Can netconsole be somehow used to see userspace messages, too?
> > > Something similar to console=3DttySX... just =3Dnetconsole.
> >
> > AFAIK it can't, but AFAICR some time ago the netconsole maintainer
> > gave some hope to some Debian guy with a similar question.
>
> It is, as they say, just a simple matter of programming to get a full
> bidirectional console out of it. As cool as that would be, I just
> haven't had time for it.

Unidirectional console would be enough for me but it seems that netcons=
ole=20
isn't capable even for that (userspace messages).

--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
