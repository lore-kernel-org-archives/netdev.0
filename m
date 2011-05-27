From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] atm: expose ATM device index in sysfs
Date: Fri, 27 May 2011 16:57:49 +0200
Message-ID: <1306508269.3445.0.camel@edumazet-laptop>
References: <1306432057.3151.10.camel@dcbw.foobar.com>
	 <1306432509.2543.1.camel@edumazet-laptop>
	 <1306434959.3151.39.camel@dcbw.foobar.com>
	 <1306507915.22126.2.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	David Woodhouse <dwmw2@infradead.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35092 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280Ab1E0O5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 10:57:55 -0400
Received: by wwk4 with SMTP id 4so5491580wwk.1
        for <netdev@vger.kernel.org>; Fri, 27 May 2011 07:57:53 -0700 (PDT)
In-Reply-To: <1306507915.22126.2.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 mai 2011 =C3=A0 09:51 -0500, Dan Williams a =C3=A9crit :
> It's currently exposed only through /proc which, besides requiring
> screen-scraping, doesn't allow userspace to distinguish between two
> identical ATM adapters with different ATM indexes.  The ATM device in=
dex
> is required when using PPPoATM on a system with multiple ATM adapters=
=2E
>=20
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> ---
>=20

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


