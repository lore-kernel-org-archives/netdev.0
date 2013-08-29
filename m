From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net,stable] net: usb: Add HP hs2434 device to ZLP
 exception table
Date: Wed, 28 Aug 2013 20:01:11 -0400 (EDT)
Message-ID: <20130828.200111.1548126886406334118.davem@davemloft.net>
References: <20130825182913.2865aa1a8cefe329ab9c7a85@gmail.com>
	<20130828.182332.824853790331642993.davem@davemloft.net>
	<20130828171812.7097dc8334046b464486d4a3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
To: robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130828171812.7097dc8334046b464486d4a3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Rob Gardner <robmatic-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 28 Aug 2013 17:18:12 -0600

> Bj=F8rn says it could have a minor performance impact, but should not
> cause any loss of functionality. I don't think there's any hard data =
on
> what the performance cost might be but I know he would eventually lik=
e
> to get rid of the exception list and live with the possible performan=
ce
> impact if it means functionality for more devices.

Therefore I would recommend turning the workaround on by default and
have a white list.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
