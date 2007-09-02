From: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sun, 02 Sep 2007 15:57:30 +0200
Message-ID: <m3642txj91.fsf@maximus.localdomain>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
	<f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
	<46D99FB7.6030505@garzik.org>
	<f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
	<20070901205457.GK9260@stusta.de>
	<20070902113638.78fbd202@the-village.bc.nu>
	<Pine.LNX.4.64.0709021303001.4312@condmat1.ciencias.uniovi.es>
	<20070902115041.GM16016@stusta.de>
	<Pine.LNX.4.64.0709021416130.6181@condmat1.ciencias.uniovi.es>
	<20070902134612.28a88761@the-village.bc.nu>
	<Pine.LNX.4.64.0709021446550.6181@condmat1.ciencias.uniovi.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Constantine A. Murenin" <mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Igor Sobrado <igor-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0709021446550.6181-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org> (Igor Sobrado's message of "Sun, 02 Sep 2007 15:00:46 +0200 (CEST)")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

IANAL, but:

Igor Sobrado <igor-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org> writes:

> So, under a dual-licensed BSD/GPL code the latter license allows a
> developer to remove the GPL license itself and release a
> single-licensed BSD code if other parties want to do it?

Of course. If it wasn't legal, dual BSD/GPL would just be equal
to GPL. Now, dual BSD/GPL equals BSD.

OTOH I'd probable leave the original licence text, something like:

The actual licence conditions:
GPL or BSD or whatever.

Portions of this file were licenced under:
[the original licence text, not valid as a licence for current file]


WRT Atheros driver I'd probably leave the thing as is (i.e., BSD/GPL
= in fact BSD), unless something like 50+% of the code is rewritten -
it's mostly their hard work after all, isn't it? Not legal
requirement, though.
-- 
Krzysztof Halasa
