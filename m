From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] WAN: convert drivers to use built-in netdev_stats
Date: Fri, 04 Jul 2008 08:50:11 -0400
Message-ID: <486E1C83.4060704@garzik.org>
References: <m3d4ly4ns2.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56376 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751534AbYGDMuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:50:14 -0400
In-Reply-To: <m3d4ly4ns2.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> There is no point in using separate net_device_stats structs when
> the one in struct net_device is present. Compiles.
>=20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

applied net-next


