From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] jme: Support WoL after shutdown
Date: Sun, 24 Oct 2010 15:42:27 -0700 (PDT)
Message-ID: <20101024.154227.232753445.davem@davemloft.net>
References: <1287711220-20075-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Taoga@yandex.ru, arieslee@jmicron.com,
	devinchiu@jmicron.com, hcchao@jmicron.com, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759211Ab0JXWmE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Oct 2010 18:42:04 -0400
In-Reply-To: <1287711220-20075-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Fri, 22 Oct 2010 09:33:40 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
>=20
> Adding shutdown function that setup wake if wol is enabled.
> Add jme_phy_on in jme_set_100m_half in case it is shutting down
> or suspending when interface is down(phy_off by default).
>=20
> Reported_and_helped_by: =F3tac <Taoga@yandex.ru>
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
