From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: sierra_net: replace whitelist with ifnumber match
Date: Sun, 12 Aug 2012 23:14:18 +0200
Message-ID: <87txw7lsnp.fsf@nemi.mork.no>
References: <1344801218-11041-1-git-send-email-bjorn@mork.no>
	<20120812.134014.854116903174415727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120812.134014.854116903174415727.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Sun, 12 Aug 2012 13:40:14 -0700 (PDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Date: Sun, 12 Aug 2012 21:53:38 +0200
>
>> Please apply to "net".
>
> Simplifications and cleanups are not appropriate for the 'net'
> tree.
>
> I would say that all of the patches you posted today are
> 'net-next' material.

OK, I'll of course have to accept that.

The reason why these weren't submitted in time for -rc1 was that they
depend on

 81df2d5 USB: allow match on bInterfaceNumber

which came in through the usb tree.  So I held on to them until now to
avoid any special usb/net merging.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
