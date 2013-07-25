From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sun4i: fix timeout check
Date: Wed, 24 Jul 2013 17:04:49 -0700 (PDT)
Message-ID: <20130724.170449.530206210183666106.davem@davemloft.net>
References: <1374541758-2025-1-git-send-email-emilio@elopez.com.ar>
	<20130723133114.GG10389@lukather>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emilio@elopez.com.ar, netdev@vger.kernel.org
To: maxime.ripard@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab3GYAEu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:04:50 -0400
In-Reply-To: <20130723133114.GG10389@lukather>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Tue, 23 Jul 2013 15:31:14 +0200

> On Mon, Jul 22, 2013 at 10:09:18PM -0300, Emilio L=F3pez wrote:
>> The current timeout check is comparing two constant values, so it wo=
n't
>> ever detect a timeout. This patch reworks the affected code a bit so=
 it
>> has a chance at detecting timeouts correctly.
>>=20
>> Signed-off-by: Emilio L=F3pez <emilio@elopez.com.ar>
>=20
> Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied.
