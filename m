From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 00/14 v3] usb/net: rndis: first step toward consolidation
Date: Tue, 1 May 2012 20:17:53 +0200
Message-ID: <CACRpkda5iSbj1V3qhwmZpRR97-xeOfHwAFJASuFNrUK=HuGEYQ@mail.gmail.com>
References: <1335896085-12435-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45126 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab2EASRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 14:17:54 -0400
Received: by yhmm54 with SMTP id m54so66933yhm.19
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 11:17:53 -0700 (PDT)
In-Reply-To: <1335896085-12435-1-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 1, 2012 at 8:14 PM, Linus Walleij <linus.walleij@linaro.org> wrote:

> This version of the patch set squashes ex. patch 3/15 into 2/15
> and creates a patch set that is bisectable at every step without
> compile warnings.

Bah forget this, I'll send a v4 from the *right* branch... :-(
(Yes I deleted the false branch now.)

Yours,
Linus Walleij
