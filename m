From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 00/17] netdev: Fix queue count
 initialisation
Date: Tue, 28 Sep 2010 14:07:27 +0200
Message-ID: <1285675647.3154.16.camel@edumazet-laptop>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
	 <20100927.221240.28820650.davem@davemloft.net>
	 <1285675327.2282.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50134 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237Ab0I1MHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 08:07:33 -0400
Received: by fxm3 with SMTP id 3so2504935fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 05:07:32 -0700 (PDT)
In-Reply-To: <1285675327.2282.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 13:02 +0100, Ben Hutchings a =C3=A9cr=
it :

> That seems a bit premature, as the driver maintainers have not had a
> chance to review these.  If it's not too late, perhaps you could roll
> these changes back for now.

I am afraid its not possible.

If you want to revert, please submit a patch.

However, changes should be small and we have some time before Linus
opens 2.6.37, dont you think ?



