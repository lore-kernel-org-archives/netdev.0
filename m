From: Ismail =?iso-8859-1?q?D=F6nmez?= <ismail-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Tue, 13 Feb 2007 18:57:01 +0200
Message-ID: <200702131857.02369.ismail@pardus.org.tr>
References: <45CCE3CA.4050904@linux.intel.com> <200702131558.48987.ismail@pardus.org.tr> <b6a2187b0702130710s217281c4k5ed227995c09c878@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "James Ketrenos" <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Jeff Chua" <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b6a2187b0702130710s217281c4k5ed227995c09c878-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 February 2007 17:10:24 Jeff Chua wrote:
> On 2/13/07, Ismail D=F6nmez <ismail-caicS1wCkhO6A22drWdTBw@public.gmane.org> wrote:
> > Tried this is on a patched 2.6.20 kernel with ipw3945 device and it
> > always puts the card in 802.11a mode instead of 802.11bg mode.
> >
> > Ideas?
>
> Before running  "iwconfig wlan0 channel 8",  the card is set to
> 802.11a mode. iwconfig shows rate at 54Mb/s. But after setting the
> channel, it sets to 802.11b mode, and I can't find a way to change
> from 11Mb/s to 54MB/s.
>
> "iwlist eth0 rate" only show up to 11Mb/s.
>
> So, my problem is the card is always in 802.11b mode.

So I guess there is a common problem with a/bg modes?

Regards,
ismail


-
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
