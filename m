From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Adding read memory barriers
Date: Tue, 08 May 2012 14:39:51 -0400 (EDT)
Message-ID: <20120508.143951.1433269599287007774.davem@davemloft.net>
References: <4FA822C4.60809@gmail.com>
	<4FA96770.9070009@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tshimizu818@gmail.com
To: erwanaliasr1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756483Ab2EHSj5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 14:39:57 -0400
In-Reply-To: <4FA96770.9070009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Erwan Velu <erwanaliasr1@gmail.com>
Date: Tue, 08 May 2012 20:35:28 +0200

> Le 07/05/2012 21:30, Erwan Velu a =E9crit :
>> From bb1e271db0fa1a29df19bede69faf8004389132d Mon Sep 17 00:00:00 20=
01
>> From: Erwan Velu <erwan.velu@zodiacaerospace.com>
>> Date: Mon, 7 May 2012 19:15:29 +0000
>> Subject: [PATCH 1/1] pch_gbe: Adding read memory barriers
>=20
> Does my patch can be considered as acceptable or shall I rework
> something on it ?

You never need to ask questions like this.

Your patch is queued up to be reviewed in patchwork:

http://patchwork.ozlabs.org/project/netdev/list/

Therefore you only make more work for maintainers and irritate them by
asking this, and therefore it will take even longer for them to get to
your patch.
