From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Quick Fair Queue scheduler maturity and examples
Date: Thu, 27 Oct 2011 13:59:32 +0200
Message-ID: <1319716772.2601.26.camel@edumazet-laptop>
References: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Karel Rericha <karel@maxtel.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50502 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299Ab1J0L7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 07:59:46 -0400
Received: by ggnb1 with SMTP id b1so2546611ggn.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 04:59:46 -0700 (PDT)
In-Reply-To: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 octobre 2011 =C3=A0 13:30 +0200, Karel Rericha a =C3=A9crit=
 :
> Hi list,
>=20
> has anyone some experience about QFQ and its maturity ? I was not abl=
e
> to find anything more than patches and papers, real world examples an=
d
> info are nonexistent.
>=20

At its inclusion time (in linux 3.0), I did many tests and feedback to
Stephen.

By the way, QFQ is not only patches and papers, its now officially
supported by linux netdev team ;)

Unfortunately the machine where I kept traces of my qfq scripts was
totally lost, no backups.... oh well...

Given that not a single patch was added since initial commit, I guess
nobody really uses the thing, or its perfect, who knows :)

You definitely should be able to use it, and report here problems if
any.
