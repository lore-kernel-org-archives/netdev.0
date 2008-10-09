From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: small design problem with hso driver
Date: Thu, 9 Oct 2008 11:11:56 +0100
Message-ID: <20081009111156.608243a7@lxorguk.ukuu.org.uk>
References: <48ECBB26.7080402@option.com>
	<20081008174556.GA15387@kroah.com>
	<48EDC887.8010403@option.com>
	<20081009103259.066cc94a@lxorguk.ukuu.org.uk>
	<48EDD556.1070508@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Filip Aben <F.Aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Paul Hardwick <P.Hardwick-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <48EDD556.1070508-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 09 Oct 2008 11:56:38 +0200
Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org> wrote:

> Hi Alan,
> No they are not.
> Have a look at.
> /drivers/char/nozomi.c
> admittedly it's written by some of the same guys.

Nozomi still has lots and lots of bugs left. Compared to the original its
now a work of art and much good stuff has been done but it is not by any
means 'done'.

File a bug with the nozomi author
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
