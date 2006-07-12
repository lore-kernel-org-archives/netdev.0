From: Bodo Eggert <7eggert@elstempel.de>
Subject: Re: [patch] do not allow IPW_2100=Y or IPW_2200=Y
Date: Wed, 12 Jul 2006 22:56:15 +0200
Message-ID: <E1G0ll6-0000vg-19@be1.lrz>
References: <6x7TQ-87H-17@gated-at.bofh.it> <6x8df-8wm-13@gated-at.bofh.it> <6xbaZ-4NX-1@gated-at.bofh.it> <6xyhj-5Fq-19@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-09.arcor-online.net ([151.189.21.49]:42980 "EHLO
	mail-in-09.arcor-online.net") by vger.kernel.org with ESMTP
	id S1751248AbWGLU5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:57:08 -0400
To: Pavel Machek <pavel@ucw.cz>, Michael Buesch <mb@bu3sch.de>,
	Jeff Garzik <jgarzik@pobox.com>, yi.zhu@intel.com,
	jketreno@linux.intel.com, Netdev list <netdev@vger.kernel.org>,
	linville@tuxdriver.com, kernel list <linux-kernel@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@ucw.cz> wrote:

> +++ linux-mm/drivers/net/wireless/ipw2200.c=A0

These are all uses of needs_reinit:

> +static int needs_reinit =3D 1;

> +             needs_reinit =3D 1;

I asume there is something missing.
--=20
Ich danke GMX daf=FCr, die Verwendung meiner Adressen mittels per SPF
verbreiteten L=FCgen zu sabotieren.

http://david.woodhou.se/why-not-spf.html
