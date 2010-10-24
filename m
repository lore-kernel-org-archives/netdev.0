From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-2.6] jme: Support WoL after shutdown
Date: Sun, 24 Oct 2010 16:18:35 -0700 (PDT)
Message-ID: <20101024.161835.233683772.davem@davemloft.net>
References: <1287962062-30714-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Taoga@yandex.ru, arieslee@jmicron.com,
	devinchiu@jmicron.com, hcchao@jmicron.com, ethanhsiao@jmicron.com
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53675
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751086Ab0JXXSM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Oct 2010 19:18:12 -0400
In-Reply-To: <1287962062-30714-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Mon, 25 Oct 2010 07:14:22 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
>=20
> Adding shutdown function that setup wake if wol is enabled.
> Add jme_phy_on in jme_set_100m_half in case it is shutting down
> or suspending when interface is down(phy_off by default).
>=20
> v2 updates:
> Removed CONFIG_PM ifdef for jme_set_100m_half and jme_wait_link.
> It would be nice if it can be applied to net-2.6 along with other pat=
ches
> sent few days ago. If it is not appropriate, please ignore the net-2.=
6
> request, and apply it to net-next-2.6 as previous patch. :)
>=20
> Reported-and-helped-by: =F3tac <Taoga@yandex.ru>
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
