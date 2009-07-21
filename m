From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Tue, 21 Jul 2009 12:42:17 -0700 (PDT)
Message-ID: <20090721.124217.03326492.davem@davemloft.net>
References: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33600
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755555AbZGUTmM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 15:42:12 -0400
In-Reply-To: <1247824566-9141-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Fri, 17 Jul 2009 12:56:06 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Many Nokia handsets support a Phonet interface to the cellular modem
> via a vendor-specific USB interface. CDC Phonet follows the
> Communications Device Class model, with one control interface, and
> and a pair of inactive and active data alternative interface. The lat=
er
> has two bulk endpoint, one per direction.
>=20
> This was tested against Nokia E61, Nokia N95, and the existing Phonet
> gadget function for the Linux composite USB gadget framework.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied, thanks.
