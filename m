From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 1/2] drivers: net: cpsw: use pinctrl PM helpers
Date: Mon, 10 Jun 2013 17:51:11 +0200
Message-ID: <CACRpkdbC0jRnJDSS-D04jw7QvOvSmwvnAb=NAAietMr3ZB86qQ@mail.gmail.com>
References: <1370542515-22009-1-git-send-email-mugunthanvnm@ti.com>
	<1370542515-22009-2-git-send-email-mugunthanvnm@ti.com>
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
Received: from mail-ob0-f177.google.com ([209.85.214.177]:64435 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab3FJPvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:51:11 -0400
Received: by mail-ob0-f177.google.com with SMTP id ta17so10090505obb.22
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:51:11 -0700 (PDT)
In-Reply-To: <1370542515-22009-2-git-send-email-mugunthanvnm@ti.com>
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
