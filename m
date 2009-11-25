From: Steve.Glendinning-sdUf+H5yV5I@public.gmane.org
Subject: Re: [patch]USB autosuspend for cdc-ether
Date: Wed, 25 Nov 2009 13:29:00 +0000
Message-ID: <OF4FE9C59B.DA63AAE2-ON80257679.0046C1C2-80257679.004A1287@smsc.com>
References: <200911250939.33127.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org,
	"Torgny Johansson" <torgny.johansson-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200911250939.33127.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> wrote on 25/11/2009 08:39:33:

> Hi,
> 
> this version should fix what you mentioned.

Thanks, it does.

checkpatch.pl still shows 31 errors though, mostly trailing whitespace, 
and the patch doesn't cleanly apply to net-next-2.6.  Two hunks fail to 
apply in cdc_ether.c.

Steve
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
