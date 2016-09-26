From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH] net: tg3: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 26 Sep 2016 09:54:19 -0700
Message-ID: <CACKFLimMGdATEoFZih5ZWRw0uZn=ibek9ffNJ=P46bX=OmU-_w@mail.gmail.com>
References: <1474839084-10883-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474839084-10883-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 25, 2016 at 2:31 PM, Philippe Reynes <tremyfr@gmail.com> wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Looks good to me.  Thanks.
Acked-by: Michael Chan <michael.chan@broadcom.com>
