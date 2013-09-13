From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/7] ptp: switch to use gpiolib
Date: Fri, 13 Sep 2013 15:36:59 +0200
Message-ID: <20130913133659.GA11394@localhost.localdomain>
References: <1378816260-8091-1-git-send-email-linus.walleij@linaro.org>
 <20130910141912.GB5088@netboy>
 <CACRpkdZOCkLmgQHZSiqQfvLp=WzNsaE5AcY3siJ0b=bL0Xv8Pg@mail.gmail.com>
 <m38uz0vrlz.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Walleij <linus.walleij@linaro.org>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Imre Kaloz <kaloz@openwrt.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:53293 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758208Ab3IMNhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 09:37:14 -0400
Content-Disposition: inline
In-Reply-To: <m38uz0vrlz.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 13, 2013 at 02:22:16PM +0200, Krzysztof Halasa wrote:
> Linus Walleij <linus.walleij@linaro.org> writes:
> 
> > Thanks, I have found numerous active hobbyists using the
> > IXP4-based NSLU2 NAS machine for various things - mostly
> > non-network related as it happens, so it'll be with us for a
> > while I think.
> 
> IXP42x are most probably "end of life" in the commercial sense, but the
> newer IXP46x/455 and even newer IXP43x are still being sold. For
> example, Gateworks have a couple of IXP43x boards ("Cambria") which
> I personally find interesting, for some specific applications.

I was really talking about the IXP465 with its PTP function. The Intel
devel board had a silicon bug making the PTP function useless. But
even if the bug got fixed, still the PTP function was very limiting.

I never got any feedback about the IXP465 PTP stuff, and so I doubt
whether anyone is really using the Linux PTP driver on the IXP465, but
you never know.

Thanks,
Richard
