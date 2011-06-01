From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCHv3] caif: Add CAIF HSI Link layer driver
Date: Thu, 2 Jun 2011 01:32:03 +0200
Message-ID: <BANLkTinxKh_3CQXJoEPzPX1OPiUH0wBD8g@mail.gmail.com>
References: <1306934958-5666-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Dmitry.Tarnyagin" <Dmitry.Tarnyagin@stericsson.com>,
	Carlos Chinea <carlos.chinea@nokia.com>,
	mark.crewell@stericsson.com, pawel.szyszuk@stericsson.com
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34525 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757196Ab1FAXcE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 19:32:04 -0400
Received: by iyb14 with SMTP id 14so236149iyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 16:32:03 -0700 (PDT)
In-Reply-To: <1306934958-5666-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/6/1 Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>:

> This driver implements a platform driver to accommodate for a
> platform specific HSI devices. A general platform driver is not
> possible as there are no HSI side Kernel API defined.

That's being worked on, Carlos has a patch stack for OMAP
and I recently submitted an initial version for ux500 as well.
I'm optimistically expecting this for Linux 3.1.

Yours,
Linus Walleij
