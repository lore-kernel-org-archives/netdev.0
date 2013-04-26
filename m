From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Fri, 26 Apr 2013 22:50:18 +0200
Message-ID: <20130426205018.GA18092@electric-eye.fr.zoreil.com>
References: <20130426132254.GA22821@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Lance Lassetter <lancelassetter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47641 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3DZUuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 16:50:21 -0400
Content-Disposition: inline
In-Reply-To: <20130426132254.GA22821@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lance Lassetter <lancelassetter@gmail.com> :
[...]
> the box serves as a network router so it is causing abundant network
> traffic problems.
>=20
> any debugging i could help you with, please let me know.=C2=A0 also i=
f there
> is a possible solution, please let me know.

Is it a regression and / or an Asus M5A97 system ?

The XID lines that the kernel printed when the r8169 module gets loaded
may help.

--=20
Ueimor
