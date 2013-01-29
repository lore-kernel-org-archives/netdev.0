From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/1] NET: qmi_wwan: add Telit LE920 support
Date: Tue, 29 Jan 2013 10:35:50 +0100
Message-ID: <87y5fcz5zd.fsf@nemi.mork.no>
References: <1359387918-2791-1-git-send-email-dnlplm@gmail.com>
	<87k3qxnt07.fsf@nemi.mork.no>
	<CAGRyCJEThQaex9au5AbWT-hm1Vvj2jxiXuAfrgNTdTofqAYY3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGRyCJEThQaex9au5AbWT-hm1Vvj2jxiXuAfrgNTdTofqAYY3A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Daniele Palmas's message of "Tue, 29 Jan 2013 09:40:38 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> 2013/1/28 Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>:
>
>> Thanks for adding this device. But the patch doesn't apply to the
>> current "net" tree.  Care to rebase it?
>>
>
> Sure. Should I use the following git repository
>
> git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/net-next.git
>
> ?

No, the correct tree to base device additions for drivers/net/usb is

 git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git

Note that this is different from most other USB devices.

This wouldn't normally be such a big deal, but you were "lucky" and hit
a timeslot when there were unmerged conflicting changes that tree. I am
not trying to be difficult.  It just feels like it :-)

Thanks again for doing this.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
