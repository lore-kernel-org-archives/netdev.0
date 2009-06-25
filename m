From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Phonet: generate Netlink RTM_DELADDR when
 destroying a device
Date: Thu, 25 Jun 2009 02:58:41 -0700 (PDT)
Message-ID: <20090625.025841.25826997.davem@davemloft.net>
References: <1245841665-14213-1-git-send-email-remi.denis-courmont@nokia.com>
	<1245841665-14213-2-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751732AbZFYJ6g convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 05:58:36 -0400
In-Reply-To: <1245841665-14213-2-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 24 Jun 2009 14:07:45 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Netlink address deletion events were not sent when a network device
> vanished neither when Phonet was unloaded.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
