From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] of_mdio: Enable fixed PHY support if driver is a
 module
Date: Mon, 20 Jun 2016 18:52:42 -0700
Message-ID: <57689DEA.3070005@gmail.com>
References: <1466468237.26723.20.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: CT kernel <linux-kernel@lists.codethink.co.uk>,
	netdev@vger.kernel.org
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36176 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbcFUB7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 21:59:25 -0400
Received: by mail-ob0-f173.google.com with SMTP id mu6so2896290obc.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 18:59:25 -0700 (PDT)
In-Reply-To: <1466468237.26723.20.camel@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/06/2016 17:17, Ben Hutchings a =C3=A9crit :
> The fixed_phy driver doesn't have to be built-in, and it's
> important that of_mdio supports it even if it's a module.
>=20
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
