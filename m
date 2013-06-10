From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 2/2] drivers: net: davinci_mdio: use pinctrl PM helpers
Date: Mon, 10 Jun 2013 17:52:29 +0200
Message-ID: <CACRpkdbEoCANtYsQgM+jEN7shGM+rN5Aq=Ak6GHzZ50d=AcC0w@mail.gmail.com>
References: <1370542515-22009-1-git-send-email-mugunthanvnm@ti.com>
	<1370542515-22009-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Linux-OMAP <linux-omap@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:60421 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab3FJP5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:57:36 -0400
Received: by mail-oa0-f51.google.com with SMTP id i4so2036662oah.38
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:57:36 -0700 (PDT)
In-Reply-To: <1370542515-22009-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 6, 2013 at 8:15 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:

> This utilize the new pinctrl core PM helpers to transition
> the driver to "default" and "sleep" states.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

This version of the patch applied with DaveM:s ACK.

Yours,
Linus Walleij
