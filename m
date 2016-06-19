From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: bcmsysport: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sun, 19 Jun 2016 13:56:44 -0700
Message-ID: <5767070C.5040203@gmail.com>
References: <1466361549-6291-1-git-send-email-tremyfr@gmail.com>
 <1466361549-6291-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34402 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbcFSVFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 17:05:04 -0400
In-Reply-To: <1466361549-6291-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/06/2016 11:39, Philippe Reynes a =C3=A9crit :
> There are two generics functions phy_ethtool_{get|set}_link_ksettings=
,
> so we can use them instead of defining the same code in the driver.
>=20
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
