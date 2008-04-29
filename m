From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Driver for IXP4xx built-in Ethernet ports
Date: Tue, 29 Apr 2008 02:01:03 -0400
Message-ID: <4816B99F.7040102@garzik.org>
References: <m3r6d05ucg.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53428 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754230AbYD2GBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 02:01:05 -0400
In-Reply-To: <m3r6d05ucg.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> Adds a driver for built-in IXP4xx Ethernet ports.
>=20
> Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

the ifdefs are really ugly and want cleaning, but the rest seems sane.=20
applied

