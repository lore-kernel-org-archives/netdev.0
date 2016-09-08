From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2 v3] net: smsc911x: augment device tree bindings
Date: Wed, 07 Sep 2016 21:06:09 -0700 (PDT)
Message-ID: <20160907.210609.2211064731014564027.davem@davemloft.net>
References: <1473256411-13965-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org,
        linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, jeremy.linton-5wv7dgnIgG8@public.gmane.org,
        kamlakant.patel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, p.fedin-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473256411-13965-1-git-send-email-linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Date: Wed,  7 Sep 2016 15:53:31 +0200

> This adds device tree bindings for:
> 
> - An optional GPIO line for releasing the RESET signal to the
>   SMSC911x devices
> 
> - An optional PME (power management event) interrupt line that
>   can be utilized to wake up the system on network activity.
>   This signal exist on all the SMSC911x devices, it is just not
>   very often routed.
> 
> Both these lines are routed to the SoC on the Qualcomm APQ8060
> Dragonboard and thus needs to be bound in the device tree.
> 
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Jeremy Linton <jeremy.linton-5wv7dgnIgG8@public.gmane.org>
> Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
