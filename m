From: Andrey Melnikov <temnota.am-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v3 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Wed, 24 May 2017 17:44:35 +0300
Message-ID: <CA+PODjpRgZuSeqtCV3+LAHx4kMA8deA5ABzH-Gv7XjhEZY_H=w@mail.gmail.com>
References: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
 <1490780303-18598-6-git-send-email-sean.wang@mediatek.com>
 <hn6gvd-qp1.ln1@banana.localnet> <20170524132049.GB24980@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170524132049.GB24980-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-05-24 16:20 GMT+03:00 Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>:
>> What about JUMBO frames and large MTU support? devlink support?
>
> To get the driver merged, it is better to start small, a minimal set
> of features. Other features can be added later. If these features are
> important to you, please feel free to submit patches.

There is no documentation from mediatek about this feature. Driver
from SDK v4.x contains only switching 19'th bit in GDMA1_FWD_CFG and
nothing more.
So, how to write patches? Peeking random bits in random SOC config registers?
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
