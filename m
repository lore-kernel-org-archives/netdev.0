From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH 3/3] net: fec: add phy-reset-interval for device tree probe
Date: Tue, 26 Jun 2012 11:11:35 +0200
Message-ID: <20457.31943.332545.171232@ipc1.ka-ro>
References: <1340700308-8315-1-git-send-email-shawn.guo@linaro.org>
	<1340700308-8315-4-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:58834 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab2FZJLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 05:11:45 -0400
In-Reply-To: <1340700308-8315-4-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Shawn Guo writes:
> Different boards may require different phy reset interval time.  Add
> property phy-reset-interval for device tree probe, so that the boards
> that need a longer interval time can specify it in their device tree.
>
'phy-reset-duration' would be a more appropriate name.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
