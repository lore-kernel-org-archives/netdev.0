From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH 1/1] /drivers/net/r6040.c: bad use of round_jiffies() ???
Date: Thu, 15 May 2008 23:31:37 +0200
Message-ID: <200805152331.37500.florian.fainelli@telecomint.eu>
References: <20080515212624.D56371C00093@mwinf2723.orange.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux" <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: "Christophe Jaillet" <christophe.jaillet@wanadoo.fr>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.int-evry.fr ([157.159.10.71]:48064 "EHLO
	smtp4.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbYEOVbz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 17:31:55 -0400
In-Reply-To: <20080515212624.D56371C00093@mwinf2723.orange.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Christophe,

Le Thursday 15 May 2008 23:26:22 Christophe Jaillet, vous avez =E9crit=A0=
:
> From: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
>
> Hi, here is a patch against linux/drivers/net/r6040.c.
>
> Compared to other places in the kernel, I think that this driver misu=
ses
> the function round_jiffies.

You are right, thanks for this fix.

> Signed-off-by: Christophe Jaillet <christophe.jaillet@wanadoo.fr>

Acked-by: Florian Fainelli <florian.fainelli@telecomint.eu>
