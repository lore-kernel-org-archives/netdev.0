From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Phonet: fix /proc/net/phonet with network
 namespaces
Date: Wed, 12 Aug 2009 22:17:18 -0700 (PDT)
Message-ID: <20090812.221718.61833757.davem@davemloft.net>
References: <1249996327-8460-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47616
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753156AbZHMFRI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 01:17:08 -0400
In-Reply-To: <1249996327-8460-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Tue, 11 Aug 2009 16:12:07 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> seq_open_net() and seq_release() are needed for seq_file_net().
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
