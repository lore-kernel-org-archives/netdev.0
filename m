From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH] r8152: add Linksys USB3GIGV1 id
Date: Mon, 25 Sep 2017 18:12:17 -0700
Message-ID: <CANEJEGsvfaDkftiC2+gRNnrb+prJr3y6h7xK2_Qw+cem5gCmWA@mail.gmail.com>
References: <20170922190604.108155-1-grundler@chromium.org>
 <1506351074.7827.13.camel@suse.com> <CANEJEGtM+gFC9Ofmp=UmGn5pKys9NRbsC6+ks_VqaLKWkEBS8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Oliver Neukum <oneukum@suse.com>,
        Hayes Wang <hayeswang@realtek.com>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-usb <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGtM+gFC9Ofmp=UmGn5pKys9NRbsC6+ks_VqaLKWkEBS8A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 1:17 PM, Grant Grundler <grundler@chromium.org> wrote:
...
> I didn't realize cdc_ether has a blacklist to make sure
> RTL8152|RTL8153 devices are not picked up by cdc_ether. Would you
> prefer I add this device to the blacklist in the same patch?

I've sent a V2 which also updates the blacklist in cdc_ether.

cheers,
grant
