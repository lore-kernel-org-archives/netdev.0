From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] Adding blacklist support to the pegasus driver
Date: Tue, 25 Mar 2008 21:35:28 +0100
Message-ID: <200803252135.29249.oliver@neukum.org>
References: <47E7D266.8050500@canonical.com> <200803241747.15061.oliver@neukum.org> <alpine.DEB.1.10.0803252204180.3163@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Bader <stefan.bader@canonical.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	petkan@users.sourceforge.net
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:33950 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbYCYUfa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 16:35:30 -0400
In-Reply-To: <alpine.DEB.1.10.0803252204180.3163@bender.nucleusys.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 25. M=C3=A4rz 2008 21:05:31 schrieb Petko Manolov:
> On Mon, 24 Mar 2008, Oliver Neukum wrote:
>=20
> > Am Montag 24 M=C3=A4rz 2008 schrieb Stefan Bader:
> >> I have been working on a problem which arose from the fact that (a=
t
> >> least one vendor) some vendors use the same vendor and model numbe=
r for
> >> different pieces of hardware.
> >
> > That issue can be solved with using the correct macros for probing =
that
> > include a device class check.
>=20
> Can you show a driver that is already doing that.  I am sorry to be s=
o=20
> lazy, but i can't help it... :-)

http://fixunix.com/kernel/256881-add-infamous-huawei-e220-option-c-3.ht=
ml

Just ask and you shall be answered.

	HTH
		Oliver
