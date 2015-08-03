From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] MIPS: Remove all the uses of custom gpio.h
Date: Mon, 3 Aug 2015 09:23:32 +0200
Message-ID: <20150803072332.GC16650@linux-mips.org>
References: <1438277338-7246-1-git-send-email-albeu@free.fr>
 <CACRpkdbUhYysC+mGuJY6Y8kd18LQLoWu+av81+ZD4UZo2nM-Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban Bedel <albeu@free.fr>,
	Linux MIPS <linux-mips@linux-mips.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Florian Fainelli <florian@openwrt.org>,
	Manuel Lauss <manuel.lauss@gmail.com>,
	Joe Perches <joe@perches.com>,
	Daniel Walter <dwalter@google.com>,
	Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Huacai Chen <chenhc@lemote.com>,
	Andrew Bresticker <abrestic@chromium.org>,
	James Hartley <james.hartley@imgtec.com>,
	Paul Burton <paul.burton@imgtec.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Wolfram Sang <wsa@the-dreams.de>,
	Simon Horman <horms+renesas@verge.net.au>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Varka Bhadram <varkabhadram@gmail.com>,
	Masanari Iid
To: Linus Walleij <linus.walleij@linaro.org>
Return-path: <linux-ide-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:33278 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27010954AbbHCHXtxfNY5 (ORCPT <rfc822;netdev@vger.kernel.org>
        + 4 others); Mon, 3 Aug 2015 09:23:49 +0200
Content-Disposition: inline
In-Reply-To: <CACRpkdbUhYysC+mGuJY6Y8kd18LQLoWu+av81+ZD4UZo2nM-Yw@mail.gmail.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 03, 2015 at 09:13:27AM +0200, Linus Walleij wrote:

> Very good job being done here.
> Reviewed-by: Linus Walleij <linus.walleij@linaro.org>
> 
> I guess this better go in through the MIPS tree.
> Given all the OpenWRT ports using MIPS this is excellent
> progress for a large hobbyist community.

Alban has posted a v2 [1] already but I take it that your Reviewed-by: applies
to the v2 patch as well?

  Ralf

[1] https://patchwork.linux-mips.org/patch/10828/
