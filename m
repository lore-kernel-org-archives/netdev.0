From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: bcmsysport: use phydev from struct
 net_device
Date: Sun, 19 Jun 2016 13:56:32 -0700
Message-ID: <57670700.5020502@gmail.com>
References: <1466361549-6291-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:36646 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbcFSU5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 16:57:19 -0400
In-Reply-To: <1466361549-6291-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/06/2016 11:39, Philippe Reynes a =C3=A9crit :
> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
>=20
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
