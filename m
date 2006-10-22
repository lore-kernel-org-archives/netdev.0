From: Norbert Preining <preining@logic.at>
Subject: Re: tg3 kernel bug in 2.6.18-mm3 and 2.6.19-rc2-mm2
Date: Sun, 22 Oct 2006 18:22:51 +0200
Message-ID: <20061022162251.GA11663@gamma.logic.tuwien.ac.at>
References: <20061021132239.GA29288@gamma.logic.tuwien.ac.at> <20061021.123814.106436476.davem@davemloft.net> <20061021233610.f190e0a8.akpm@osdl.org> <20061021234107.GA12918@gamma.logic.tuwien.ac.at> <1551EAE59135BE47B544934E30FC4FC093FC5D@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.logic.tuwien.ac.at ([128.130.175.20]:2255 "EHLO
	alpha.logic.tuwien.ac.at") by vger.kernel.org with ESMTP
	id S1751167AbWJVQXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 12:23:03 -0400
To: Michael Chan <mchan@broadcom.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061021233610.f190e0a8.akpm@osdl.org> <1551EAE59135BE47B544934E30FC4FC093FC5D@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all!

On Sam, 21 Okt 2006, Michael Chan wrote:
> > 2.6.19-rc2	works
> > 2.6.19-rc2+patch does not work
> >=20
> It doesn't make any sense.  This patch is totally benign and
> cannot cause the "No firmware running" and lockup that you
> reported.  Can you please double-check?

Ok, I cannot reproduce it anymore. No idea why it happened.

ANyway, with my current rc2+tg3 patch I have no problems, while with
rc2-mm2 I have the problems.

Best wishes

Norbert

-----------------------------------------------------------------------=
--------
Dr. Norbert Preining <preining@logic.at>                    Universit=E0=
 di Siena
Debian Developer <preining@debian.org>                         Debian T=
eX Group
gpg DSA: 0x09C5B094      fp: 14DF 2E6C 0307 BE6D AD76  A9C0 D2BF 4AA3 0=
9C5 B094
-----------------------------------------------------------------------=
--------
SHENANDOAH (n.)
The infinite smugness of one who knows they are entitled to a place in
a nuclear bunker.
			--- Douglas Adams, The Meaning of Liff
