From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH net-next 1/1] Phonet: convert bound sockets hash
 list to RCU
Date: Thu, 14 Apr 2011 21:34:58 -0700 (PDT)
Message-ID: <20110414.213458.226773976.davem@davemloft.net>
References: <1302686856-7742-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44995
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752141Ab1DOEfe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 00:35:34 -0400
In-Reply-To: <1302686856-7742-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 13 Apr 2011 12:27:36 +0300

> This gets rid of the last spinlock in the Phonet stack proper.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

I've applied this to net-next-2.6, please send any fixups as follow-on
patches.

Thanks.
