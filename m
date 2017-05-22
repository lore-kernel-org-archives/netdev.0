From: Jes Sorensen <jes.sorensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 00/10] rt2x00: rt2x00: improve calling conventions for
 register accessors
Date: Mon, 22 May 2017 14:03:39 -0400
Message-ID: <69171f99-0844-cfe1-7bcb-72d61f56c3c5@gmail.com>
References: <20170517144702.1381136-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Daniel Golle <daniel-g5gK2j5usbvCyp4qypjU+w@public.gmane.org>,
        Mathias Kresin <dev-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Serge Vasilugin <vasilugin-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>,
        Roman Yeryomin <roman-9zmcapQ0v8Q@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Tom Psyborg <pozega.tomislav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170517144702.1381136-1-arnd-r2nGTMty4D4@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/17/2017 10:46 AM, Arnd Bergmann wrote:
> I've managed to split up my long patch into a series of reasonble
> steps now.
> 
> The first two are required to fix a regression from commit 41977e86c984
> ("rt2x00: add support for MT7620"), the rest are just cleanups to
> have a consistent state across all the register access functions.
> 
>       Arnd

Nice work! This is a textbook example of how to do this the right way!

Reviewed-by: Jes Sorensen <jsorensen-b10kYP2dOMg@public.gmane.org>

Jes
