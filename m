From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ks8842: Support 100Mbps when accessed via timberdale
Date: Mon, 26 Jul 2010 21:05:28 -0700 (PDT)
Message-ID: <20100726.210528.241936017.davem@davemloft.net>
References: <1280134265.3498.4.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44801
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750704Ab0G0EFL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 00:05:11 -0400
In-Reply-To: <1280134265.3498.4.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Mon, 26 Jul 2010 10:51:05 +0200

> This patch removes the code which disables 100Mbps advertising when
> the ks8842 is accessed via timberdale.
>=20
> At higher speed it's good to be nice to the internal state machine
> of timberdale by acking interrupts. That is done by a write to the
> interrupt ack register (IAR).
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

Applied.
