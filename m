From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/4]: Spidernet stop queue when queue is full
Date: Wed, 4 Oct 2006 19:06:41 -0500
Message-ID: <20061005000641.GM4381@austin.ibm.com>
References: <20061003205240.GE4381@austin.ibm.com> <20061003205729.GF4381@austin.ibm.com> <200610040019.43028.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org, jeff@garzik.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:41390 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751244AbWJEAGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 20:06:45 -0400
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200610040019.43028.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 04, 2006 at 12:19:42AM +0200, Arnd Bergmann wrote:
> On Tuesday 03 October 2006 22:57, Linas Vepstas wrote:
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0result =3D NETDEV_T=
X_LOCKED;
>=20
> Hmm, this looks a little strange to me.=20

Right. This was left-over cruft from back when.

I'll fix this and resend the whole series tommorrow or friday,=20
I've got a few more minor performnace tweaks, an implementation
of NETIF_F_SG, and another fix or two, etc.

--linas

