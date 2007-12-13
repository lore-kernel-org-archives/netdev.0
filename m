From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] r6040 various cleanups
Date: Thu, 13 Dec 2007 09:33:58 +0100
Message-ID: <4760EE76.7010402@telecomint.eu>
References: <200712121044.01820.florian.fainelli@telecomint.eu> <20071212223541.GA32305@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, Andrew Morton <akpm@linux-foundation.org>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.int-evry.fr ([157.159.10.44]:45885 "EHLO
	smtp1.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761477AbXLMIeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 03:34:04 -0500
In-Reply-To: <20071212223541.GA32305@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

=46rancois Romieu a =E9crit :
> Thanks, I have split it in parts. The serie should be available short=
ly at:
>=20
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r=
6040

You are welcome, thank you for taking care of this driver !

>=20
> Please note that:
> 1. TIMER_WUT has been removed as it was not used any more
> 2. I have kept the difference below. Was the patch really supposed to=
 update
>    the same error counter twice ?

You are right, I did not pay attention to this, thanks for fixing !

