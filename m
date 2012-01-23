From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH COMMITTED] bluetooth: hci: Fix type of "enable_hs" to
 bool.
Date: Mon, 23 Jan 2012 02:56:23 +0100
Message-ID: <1327283783.1955.84.camel@aeonflux>
References: <20120122.144654.2252112633629547845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40837 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab2AWB6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 20:58:01 -0500
In-Reply-To: <20120122.144654.2252112633629547845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> net/bluetooth/hci_core.c: In function =E2=80=98__check_enable_hs=E2=80=
=99:
> net/bluetooth/hci_core.c:2587:1: warning: return from incompatible po=
inter type [enabled by default]
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>=20
> I noticed this while validating the build today, committed to 'net'.

and from your subject, I assume you rightfully just applied that patch
to your tree.

I remember that I acked such a patch, but it seems it never made it
anywhere in the end :(

Regards

Marcel
