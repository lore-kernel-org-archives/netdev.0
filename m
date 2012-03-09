From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver
 support
Date: Fri, 9 Mar 2012 13:13:10 -0800
Message-ID: <20120309211310.GA22272@kroah.com>
References: <20120306143559.GB23314@kroah.com>
 <87r4x5u478.fsf@nemi.mork.no>
 <20120308185324.GA13836@kroah.com>
 <20120308.134338.1946356302291460775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn-yOkvZcmFvRU@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120308.134338.1946356302291460775.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2012 at 01:43:38PM -0800, David Miller wrote:
> From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> Date: Thu, 8 Mar 2012 10:53:24 -0800
>=20
> > On Tue, Mar 06, 2012 at 04:41:47PM +0100, Bj=F8rn Mork wrote:
> >> I've managed to make them dependent on not-yet-merged patches in
> >> net-next as well (the initial addition of the qmi_wwan driver), so=
 I
> >> believe that will be equally difficult.  Bad planning from my side=
 I
> >> guess...
> >=20
> > I can take those patches as well if needed, to help unwind the
> > dependancy mess, and the network maintainer doesn't mind.
>=20
> I don't mind :)

Thanks, I've picked the one patch in your tree up, and applied these ne=
w
ones as well.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
