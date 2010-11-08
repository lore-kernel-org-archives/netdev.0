From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: Mon, 8 Nov 2010 15:36:27 +0200
Message-ID: <201011081536.27650.remi.denis-courmont@nokia.com>
References: <1289147492.3090.137.camel@Dan> <201011081004.48382.remi.denis-courmont@nokia.com> <1289221999.10229.28.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "chas@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>,
	"stable@kernel.org" <stable@kernel.org>
To: ext Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:65090 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751449Ab0KHNhR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 08:37:17 -0500
In-Reply-To: <1289221999.10229.28.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 November 2010 15:13:19 ext Dan Rosenberg, you wrote:
> > Seems like this patch series is incomplete to me as far as /proc/ne=
t is
> > concerned.
>=20
> I'm aware that I missed SCTP, which I will fix in the next attempt.
> Other than that (and sticking only to /proc leaks, since I realize th=
ere
> are many printk examples), care to share what was missed?

At least Phonet seems to be missing too... which makes me wonder why I =
am in=20
the Cc list.

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
