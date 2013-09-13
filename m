From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 4/7] ptp: switch to use gpiolib
Date: Fri, 13 Sep 2013 10:38:21 +0200
Message-ID: <CACRpkdZOCkLmgQHZSiqQfvLp=WzNsaE5AcY3siJ0b=bL0Xv8Pg@mail.gmail.com>
References: <1378816260-8091-1-git-send-email-linus.walleij@linaro.org>
	<20130910141912.GB5088@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Imre Kaloz <kaloz@openwrt.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:52071 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011Ab3IMIiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 04:38:22 -0400
Received: by mail-oa0-f42.google.com with SMTP id n12so896194oag.29
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 01:38:21 -0700 (PDT)
In-Reply-To: <20130910141912.GB5088@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 10, 2013 at 4:19 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Tue, Sep 10, 2013 at 02:31:00PM +0200, Linus Walleij wrote:

>> Hi Richard, I'm seeking an ACK on this patch to take it throug
>> the GPIO tree as part of a clean-out of custom GPIO implementations.
>
> I don't have this hardware for testing (it is really obsolete now),
> but the change looks okay to me.
>
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Thanks, I have found numerous active hobbyists using the
IXP4-based NSLU2 NAS machine for various things - mostly
non-network related as it happens, so it'll be with us for a
while I think.

Yours,
Linus Walleij
