From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver
 support
Date: Thu, 8 Mar 2012 10:53:24 -0800
Message-ID: <20120308185324.GA13836@kroah.com>
References: <1330528507-16551-1-git-send-email-bjorn@mork.no>
 <878vjeuebk.fsf@nemi.mork.no>
 <20120306143559.GB23314@kroah.com>
 <87r4x5u478.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87r4x5u478.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2012 at 04:41:47PM +0100, Bj=F8rn Mork wrote:
> Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> writes:
> > On Tue, Mar 06, 2012 at 01:03:11PM +0100, Bj=F8rn Mork wrote:
> >
> >> I believe I may have promised to ping you when these patches were
> >> ready.  Please apply patch 1-3 from this series to your usb-next b=
ranch
> >> (for Linux 3.4). They were acked by Oliver a week ago.
> >
> > Great, can you resend them to me please, with Oliver's ack?  I don'=
t see
> > them in my to-apply queue anymore as I thought they were still unde=
r
> > review.
>=20
> OK. Will do.
>=20
> >> Patches 4 and 5 (for netdev) will have to wait until the first 3 a=
re
> >> merged.
> >
> > I can take them through my tree if they are dependant on the first =
3,
> > that's not a problem.
>=20
> I've managed to make them dependent on not-yet-merged patches in
> net-next as well (the initial addition of the qmi_wwan driver), so I
> believe that will be equally difficult.  Bad planning from my side I
> guess...

I can take those patches as well if needed, to help unwind the
dependancy mess, and the network maintainer doesn't mind.

thanks,

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
